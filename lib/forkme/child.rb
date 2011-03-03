class Child < Forkpool
  def initialize(pid, from, to)
    @pid, @from, @to = pid, from, to
    @status = :idle
  end
  # status is one of :idle, :connect, :close, :exit

  attr_accessor :pid, :from, :to

  def event(s)
    if s == nil then
      #Forkpool.logger.debug "p: child #{pid} terminated"
      self.exit
    else
      case s.chomp
      when "connect" then @status = :connect
      when "disconnect" then @status = :idle
      else
        begin
          Forkpool.logger.error "unknown status: #{s}"
        rescue NoMethodError
        end

        return "unknown status: #{s}"
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
