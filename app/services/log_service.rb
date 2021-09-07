class LogService
    def initialize(params, message, status)
        @params = params
        @message = message
        @status = status
    end

    def warn
        smx_logger.warn(data_attributes)
    end

    def info
        smx_logger.info(data_attributes)
    end

    def fatal
        smx_logger.fatal(data_attributes)
    end

    def debug
        smx_logger.debug(data_attributes)
    end

    private

    attr_reader :params, :message, :status

    def smx_logger
        SMX_LOGGER
    end

    def data_attributes
        {
            params: params,
            message: message,
            status: status
        }
    end

end