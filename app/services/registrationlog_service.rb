class RegistrationlogService
    def initialize(params, message, status)
        @params = params
        @message = message
        @status = status
    end

    def warn
        reg_logger.warn(data_attributes)
    end

    def info
        reg_logger.info(data_attributes)
    end

    def fatal
        reg_logger.fatal(data_attributes)
    end

    def debug
        reg_logger.debug(data_attributes)
    end

    private

    attr_reader :params, :message, :status

    def reg_logger
        REGISTRATION_LOGGER
    end

    def data_attributes
        {
            params: params,
            message: message,
            status: status
        }
    end

end