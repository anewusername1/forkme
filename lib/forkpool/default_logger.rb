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
