class TransactionlogService
    def initialize(params, message, status)
        @params = params
        @message = message
        @status = status
    end

    def warn
        transaction_logger.warn(data_attributes)
    end

    def info
        transaction_logger.info(data_attributes)
    end

    def fatal
        transaction_logger.fatal(data_attributes)
    end

    def debug
        transaction_logger.debug(data_attributes)
    end

    private

    attr_reader :params, :message, :status

    def transaction_logger
        TRANSACTION_LOGGER
    end

    def data_attributes
        {
            params: params,
            message: message,
            status: status
        }
    end

end