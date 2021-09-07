class SmsService

    def initialize(params, message_type)
        @params = params
        puts "@params: #{@params}"
        phone_number = params[:phone_number]
        @phone_number = phone_number.gsub(/[^0-9A-Za-z]/, '')
        @message = ''
        @static_number = '+19174267236'

        case message_type
        when SmxTransaction.message_types[:phone_verification_]
            phone_verification_message
        when SmxTransaction.message_types[:smx_non_smx_send_]
            smx_non_smx_message
        when SmxTransaction.message_types[:smx_external_send_]
            smx_external_message
        when SmxTransaction.message_types[:smx_non_smx_cancelled_send_]
            smx_non_smx_cancelled_message
        else
            @message = ''
        end
        
    end

    def phone_verification_message
        @message = "Your SMX verification code is - #{@params[:verification_code]}"
        send_message
    end

    def smx_non_smx_message
        @message = "#{@params[:first_name]} #{@params[:last_name]} sent you #{params[:formatted_amount]}. Please download SMX app to receive the amount"
        send_message
    end

    def smx_non_smx_cancelled_message
        @message = "Your transaction of #{params[:formatted_amount]} sent to #{@params[:first_name]} #{@params[:last_name]} has been cancelled"
        send_message
    end

    def smx_external_message
        @message = "#{@params[:first_name]} #{@params[:last_name]} sent you #{@params[:formatted_amount]} on #{@params[:payout_service_name]}. Check your account for funds"
        send_message
    end

    def send_message
        if @message.present?
            pn = nil
            ph_no = "+#{@phone_number.gsub('+', '')}"
            if Phoner::Phone.valid? ph_no
                pn = Phoner::Phone.parse(ph_no)
                number_to_send_to = pn.country_code == '91' ? @static_number : @phone_number
                if Rails.env == 'staging'
                    number_to_send_to = @static_number
                end
                twilio_sid = ENV["TWILIO_SID"]
                twilio_token = ENV["TWILIO_TOKEN"]
                twilio_phone_number = ENV['TWILIO_TELEPHONE']
                begin
                    @twilio_client = Twilio::REST::Client.new twilio_sid, twilio_token
                    @twilio_client.messages.create(
                        from: "#{twilio_phone_number}",
                        to: "+#{number_to_send_to}",
                        body: @message
                    )
                rescue Twilio::REST::RestError => e
                    puts "--------------------------------------------------"
                    puts e.message
                    puts "--------------------------------------------------"
                end    
            end
        end
    end
end