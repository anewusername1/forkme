module DefaultLogger
  def DefaultLogger.info(msg)
    $stdout.puts msg
  end

  def DefaultLogger.debug(msg)
    $stdout.puts msg
  end

  def DefaultLogger.error(msg)
    $stdout.puts msg
  end
end
