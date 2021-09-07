logfile = File.open(Rails.root.join('log', 'transaction_logger.log'), 'a') #create log file
logfile.sync = true
TRANSACTION_LOGGER = TransactionLogger.new(logfile)