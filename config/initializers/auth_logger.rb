logfile = File.open(Rails.root.join('log', 'auth_logger.log'), 'a') #create log file
logfile.sync = true
AUTH_LOGGER = AuthLogger.new(logfile)