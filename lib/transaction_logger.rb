class TransactionLogger < Logger
    def format_message(severity, timestamp, progname, msg)
        "[#{timestamp.strftime("%Y%m%d.%H:%M:%S")}] #{severity}: #{msg}\n\n"
    end
end