module Errors
  class Errors < StandardError
    def status
      500
    end

    def message
      'Internal Server Error' #'Ooops! Something went wrong. Please try again.'
    end

    def to_hash
      {
        meta: {
          code: status,
          message: message
        }
      }
    end

    def to_json(*)
      to_hash.to_json
    end
  end
end
