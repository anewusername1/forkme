# a lot of code taken from tmtm's tserver v0.3.2a
# http://www.tmtm.org/ruby/tserver/

require 'socket'

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
          Loompa.logger.error "unknown status: #{s}"
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
  
  attr_writer :on_child_start, :on_child_exit, :max_forks
  
  # These class methods actually set up the logger that's used
  # to print out useful information
  class << self
    def logger
      @logger
    end
    
    def logger=(log_meth)
      @logger = log_meth
    end
  end
  
  def initialize(forks_to_run, log_method = DefaultLogger)
    @min_forks = 1
    @max_forks = forks_to_run
    Loompa.logger = log_method
  end
  
  # class variable holding all the children
  @@children = Children.new
  
  # A block to be executed just before calling the block a child
  # will be executing
  #
  # [block] block The block that will be executed
  def on_child_start(&block)
    if block == nil then
      raise "block required"
    end
    @on_child_start = block
  end
  
  # A block to be executed upon exiting a child process.
  #
  # [block] block The block that will be executed upon termination of a child process
  def on_child_exit(&block)
    if block == nil then
      raise "block required"
    end
    @on_child_exit = block
  end
  
  # Starts the child processes, the number of which is determined by the @max_forks variable
  #
  # [block] &block The block that will be executed by the child processes
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

  # sets the @flag to :exit_loop, essentially stopping the parent and child processes
  # since the loop will die and all children will receive the close() call
  def stop()
    @flag = :exit_loop
  end

  # Calls the close method on each child which sets its status to :closed
  def terminate()
    raise "Cannot terminate while still in the loop" if @flag == :in_loop
    @@children.each do |c|
      c.close
    end
  end

  # Sends the TERM signal to all child processes via their pids
  def interrupt()
    Process.kill "TERM", *(@@children.pids) rescue nil
  end

  private

  # called by the child process when it's finished the block passed to it
  def exit_child
    @on_child_exit.call if defined? @on_child_exit
    exit!
  end

  # Creates a child process and tells that process to execute a block
  # It also sets up the to and from pipes to be shared between the 
  # parent and child processes.
  #
  # [block] block The block to be executed by the child
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
  
  # Method to call the block that's been passed to it
  #
  # [block] the block that will be called within the child process
  def child(block)
    #Loompa.logger.debug "c: start"
    # Handle these different signals the child might encounter
    # This signal trapping actually does get handled within the child
    #    since it's called from within the fork method
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
  
  # Creates signal traps for the array of signals passed to it
  #
  # [Array] sigs The signals that will be trapped
  def handle_signals(sigs)
    sigs.each do |signal|
      trap(signal) { exit_child }
    end
  end
end
