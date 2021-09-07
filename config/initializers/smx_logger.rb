logfile = File.open(Rails.root.join('log', 'smx_logger.log'), 'a') #create log file
logfile.sync = true
SMX_LOGGER = SmxLogger.new(logfile)