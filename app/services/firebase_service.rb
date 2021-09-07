class FirebaseService
    def initialize(tokens, options)
        @tokens = tokens
        @options = options
    end

    def send_notification
        fcm = FCM.new(ENV['FCM_SERVER_KEY'])
        @tokens.each_slice(900) do | batch |
            response = fcm.send(batch, @options)
            puts response
        end
    end

end