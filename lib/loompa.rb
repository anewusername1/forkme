require 'socket'
require 'drb/drb'
require 'rinda/ring'
require 'rinda/tuplespace'

module DefaultLogger
  def DefaultLogger.info(msg)
    STDOUT.puts msg
  end
  
  def DefaultLogger.debug(msg)
    STDOUT.puts msg
  end
  
  def DefaultLogger.error(msg)
    STDOUT.puts msg
  end
end

class Loompa 
  include DefaultLogger
  attr_reader :child_count
  
  class Children < Array
    def fds()
      self.map{|c| c.active? ? c.from : nil}.compact.flatten
    end

    def pids()
      self.map{|c| c.pid}
    end

    def active()
      self.map{|c| c.active? ? c : nil}.compact
    end

    def idle()
      self.map{|c| c.idle? ? c :  nil}.compact
    end

    def by_fd(fd)
      self.each do |c|
        return c if c.from == fd
      end
      nil
    end

    def cleanup()
      new = Children.new
      self.each do |c|
        begin
          if Process.waitpid(c.pid, Process::WNOHANG) then
            #Loompa.logger.debug "p: catch exited child #{c.pid}"
            c.exit
          else
            new << c
          end
        rescue Errno::ECHILD
        end
      end
      self.replace new
    end
  end
  
  class Child
    def initialize(pid, from, to)
      @pid, @from, @to = pid, from, to
      @status = :idle
    end
    # status is one of :idle, :connect, :close, :exit

    attr_accessor :pid, :from, :to

    def event(s)
      if s == nil then
        #Loompa.logger.debug "p: child #{pid} terminated"
        self.exit
      else
        case s.chomp
        when "connect" then @status = :connect
        when "disconnect" then @status = :idle
        else
          $stderr.puts "unknown status: #{s}"
        end
      end
    end

    def close()
      @to.close unless @to.closed?
      @status = :close
    end

    def exit()
      @from.close unless @from.closed?
      @to.close unless @to.closed?
      @status = :exit
    end

    def idle?()
      @status == :idle
    end

    def active?()
      @status == :idle or @status == :connect
    end
  end
  
  attr_writer :on_child_start, :on_child_exit
  attr_accessor :max_servers, :handle_signal
  
  class << self
    def logger
      @logger
    end
    
    def logger=(log_meth)
      @logger = log_meth
    end
  end
   
  def initialize(forks_to_run, port, log_method = DefaultLogger)
    @handle_signal = false
    @min_forks = 1
    @max_forks = forks_to_run
    @port = port
    @child_count = 0
    Loompa.logger = log_method
  end
  
  @@children = Children.new
  
  def on_child_start(&block)
    if block == nil then
      raise "block required"
    end
    @on_child_start = block
  end

  def on_child_exit(&block)
    if block == nil then
      raise "block required"
    end
    @on_child_exit = block
  end
  
  def start(&block)
    if block == nil then
      raise "block required"
    end
    (@min_forks - @@children.size).times do
      make_child block
    end
    @flag = :in_loop
    while @flag == :in_loop do
      log = false
      r, = IO.select(@@children.fds, nil, nil, 1)
      if r then
        log = true
        r.each do |f|
          c = @@children.by_fd f
          c.event f.gets
        end
      end
      as = @@children.active.size
      @@children.cleanup if @@children.size > as
      break if @flag != :in_loop
      n = 0
      if as < @min_forks then
        n = @min_forks - as
      else
        if @@children.idle.size <= 2 then
          n = 2
        end
      end
      if as + n > @max_forks then
        n = @max_forks - as
      end
      #Loompa.logger.debug "p: max:#{@max_forks}, min:#{@min_forks}, cur:#{as}, idle:#{@@children.idle.size}: new:#{n}" if n > 0 or log
      n.times do
      	make_child block
      end
    end
    @flag = :out_of_loop
    terminate
  end
  
  def close()
    if @flag != :out_of_loop then
      raise "close() must be called out of start() loop"
    end
    @socks.each do |s|
      s.close
    end
  end

  def stop()
    @flag = :exit_loop
  end

  def terminate()
    @@children.each do |c|
      c.close
    end
  end

  def interrupt()
    Process.kill "TERM", *(@@children.pids) rescue nil
  end

  private
  
  def exit_child
    #Loompa.logger.debug "c: exiting"
    exit!
  end

  def make_child(block)
    #Loompa.logger.debug "p: make child"
    to_child = IO.pipe
    to_parent = IO.pipe
    pid = fork do
      @@children.map do |c|
        c.from.close unless c.from.closed?
        c.to.close unless c.to.closed?
      end
      @from_parent = to_child[0]
      @to_parent = to_parent[1]
      to_child[1].close
      to_parent[0].close
      child block
    end
    #Loompa.logger.debug "p: child pid #{pid}"
    @@children << Child.new(pid, to_parent[0], to_child[1])
    to_child[0].close
    to_parent[1].close
  end
  
  def child(block)
    #Loompa.logger.debug "c: start"
    handle_signals(["TERM", "INT", "HUP"])
    @on_child_start.call if defined? @on_child_start
    #Loompa.logger.debug "c: connect from client"
    @to_parent.syswrite "connect\n"
    begin
      block.call
    rescue => e
      Loompa.logger.error e.message
      Loompa.logger.error e.backtrace.join("\n")
    end
    #Loompa.logger.debug "c: disconnect from client"
    @to_parent.syswrite "disconnect\n" rescue nil
    exit_child
  end
  
  def handle_signals(sigs)
    sigs.each do |signal|
      trap(signal) { exit_child }
    end
  end
end
