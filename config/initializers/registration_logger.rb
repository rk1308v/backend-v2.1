logfile = File.open(Rails.root.join('log', 'registration_logger.log'), 'a') #create log file
logfile.sync = true
REGISTRATION_LOGGER = RegistrationLogger.new(logfile)