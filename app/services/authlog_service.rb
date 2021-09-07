class AuthlogService
    def initialize(params, message, status)
        @params = params
        @message = message
        @status = status
    end

    def warn
        auth_logger.warn(data_attributes)
    end

    def info
        auth_logger.info(data_attributes)
    end

    def fatal
        auth_logger.fatal(data_attributes)
    end

    def debug
        auth_logger.debug(data_attributes)
    end

    private

    attr_reader :params, :message, :status

    def auth_logger
        AUTH_LOGGER
    end

    def data_attributes
        {
            params: params,
            message: message,
            status: status
        }
    end

end