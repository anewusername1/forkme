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