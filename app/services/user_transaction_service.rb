class UserTransactionService
    require "uri"

    def initialize(user,recipient, amount, trans_type, description, is_confirmed, recepient_telephone, country_code)
        @user  = user
        @recipient = recipient
        @amount = amount
        @trans_type = trans_type
        @description = description
        @message = []
        @code = ""
        @response_message = []
        @user_transaction_countries = ["usa", "bfa", 'ken', 'KEN']
        @is_confirmed = is_confirmed
        @recepient_telephone = recepient_telephone
        @country_code = country_code

        @params_data = {action: 'send_money', controller: 'UserTransactionService', user: @user.id, recepient: @recipient.blank? ? '' : @recipient.id, amount: @amount, trans_type: @trans_type, description: @description, recepient_telephone: @recepient_telephone, country_code: @country_code}

        check_service_availability
        check_user
        check_recipient
        get_user_country
        get_recepient_country
        puts("Recep: #{@recepient_country} - #{recepient_telephone}")
        set_recepient_type

        set_exchange_rate

        if trans_type == SmxTransaction.trans_types[:send_]
            set_account
            set_fees
            check_balance
        end
    end

    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    #    Send Money
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    def send_money  
        if @message.count == 0
            @notice_type = TransferNotification.notice_types[:send_]
            @trans_status = SmxTransaction.statuses[:pending_]
            @payment_type = SmxTransaction.payment_types[:smx_account_]
            
            @user_currency_code = @user_country.currency.iso_code
                
            @recepient_currency_code = @recepient_country.currency.iso_code

            if @exchange_rate > 0
                if @is_confirmed == 0
                    resp_hash = { 
                                    status: 200, 
                                    message: "Detail of your transaction. Please confirm.", 
                                    time_stamp: Time.now.to_i, 
                                    fees: @fees, 
                                    exchange_rate: @exchange_rate, 
                                    recipient_username: @recipient.blank? ? @recepient_telephone : @recipient.username, 
                                    payment_type: @payment_type 
                                }
                    if @recipient.present?
                        resp_hash[:recipient_id] = @recipient.id
                    end
                    if @recipient_telephone.present?
                        resp_hash[:recipient_telephone] = @recipient_telephone
                    end
                    @response_message = resp_hash
                else
                    @user_transaction = UserTransaction.create! net_amount: BigDecimal(@amount), 
                                                fees: @fees, 
                                                exchange_rate: @exchange_rate, 
                                                sender_id: @user.id,
                                                recipient_id: @recipient.blank? ? nil : @recipient.id,
                                                country_from: @user_country,
                                                country_to: @recepient_country,
                                                status: @trans_status, 
                                                payment_type: @payment_type,
                                                trans_type: @trans_type,
                                                recipient_telephone: @recepient_telephone.blank? ? '' : @recepient_telephone,
                                                recipient_type: @recepient_type
                    
                    if @user_transaction
                        payment_service = @user_transaction.detect_payment_service
                        if payment_service.blank?
                            @user_transaction = nil
                            LogService.new(@params_data, "Country transfer not supported", 500).fatal
                            UserMailer.trans_error_email(@params_data).deliver_now
                            return {status: 500, message: "Country transfer not supported", time_stamp: Time.now.to_i}
                        else
                            @user_transaction.payment_service = payment_service
                            @user_transaction.save
                            pay_data = @user_transaction.payment_service.pay(@user_transaction.id)
                            puts("pay_data: #{pay_data}")
                            if pay_data[:status] == 200
                                return pay_data
                            else
                                LogService.new(@params_data, "Something went wrong. Try again later.", 500).fatal
                                UserMailer.trans_error_email(@params_data).deliver_now
                                return { status: 500, error: "Something went wrong. Try again later."}
                            end
                        end
                    else
                        LogService.new(@params_data, "Something went wrong. Try again later.", 500).fatal
                        UserMailer.trans_error_email(@params_data).deliver_now
                        return { status: 500, error: "Something went wrong. Try again later."}
                    end
                end
            else
                LogService.new(@params_data, "Country transfer not supported", 500).fatal
                UserMailer.trans_error_email(@params_data).deliver_now
                @response_message = {status: 500, message: "Country transfer not supported", time_stamp: Time.now.to_i}
            end
        else 
            @response_message = { status: 412, code: @code, error: @message.first }  # Status 412 for failed precondition
        end
        return @response_message
    end

    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    #    Request Money
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    def request_money
        if @message.count == 0
            @notice_type = TransferNotification.notice_types[:request_]
            #@trans_status = SmxTransaction.statuses[:completed_]
            formatted_amount = @user.get_formatted_amount BigDecimal(@amount), @user.country
            @user_activity = "Requested #{formatted_amount} from #{@user.username}"
            #@recipient_notice = "@#{@user.username} sent you a request for #{formatted_amount}"
            @recipient_notice = "@#{@user.username} sent you a pay request"
            if @description
                @recipient_notice = @recipient_notice + " with a note: #{@description}"
            end
            ActiveRecord::Base.transaction do
                begin
                    create_user_activity
                    create_recipient_notification
                    message  = "Your request was sent successfully"
                    message = "Money Requested Successfully"
                    @response_message << { status: 200, message: message}
                rescue => e
                    puts e
                    @response_message <<  { status: 500, error: "Something went wrong. Try again later."}
                    raise ActiveRecord::Rollback
                end
            end
        else
            @response_message << { status: 412, error: @message.first } # Status 412 for failed precondition
        end
        return @response_message
    end

    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    #    Utility Functions
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    private
    def check_service_availability
        unless @user_transaction_countries.include? @user.country.downcase
            @message << "This service is not currently available in your country"
        end
    end

    def check_user
        if @message.count == 0
            if !@user.phone_verified
                @message << "You need to verify your phone number to make this transaction" #if !@user.phone_verified
                @code = SmxTransaction.trans_error_codes[:phone_not_verfied_]
            elsif !@user.email_verified
                @message << "You need to verify your email address to make this transaction" #if !@user.email_verified
                @code = SmxTransaction.trans_error_codes[:email_not_verified_]
            else
                @message << "We Cannot fulfill this request. Your account is not found" if !@user.try(:account).present?
                @message << "We Cannot fulfill this request. Your profile is not found" if !@user.try(:account).try(:profile).present?
            end
        end
    end

    def check_recipient
        if @message.count == 0
            if @recipient.blank?
                if @recepient_telephone.blank?
                    @message << "Recipient not found"
                    @code = SmxTransaction.trans_error_codes[:recep_not_present_]
                end
            else
                @message << "Recipient account not found" if !@recipient.try(:account).present?
                @message << "Recipient profile not found" if !@recipient.try(:account).try(:profile).present?
                @message << "You cannot send or request money from yourself" if @user.id == @recipient.try(:id)
            end
        end
    end

    def get_user_country
        if @message.count == 0
            @user_country = ISO3166::Country.find_country_by_alpha3(@user.country)
            if @user_country.blank?
                @message << 'Country transfer not supported'
            end
        end
    end

    def get_recepient_country
        if @message.count == 0
            if @recipient.present?
                @recepient_country = ISO3166::Country.find_country_by_alpha3(@recipient.country)
            elsif @recepient_telephone.present?
                ph_no = "+#{@recepient_telephone.gsub('+', '')}"
                if Phoner::Phone.valid? ph_no
                    @recepient_country = PhonerService.new(ph_no).detect_country
                else
                    puts("Phone invalid")
                end
            end
            @message << 'Recepient country not supported' if @recepient_country.blank?
        end
    end

    def set_recepient_type
        if @message.count == 0
            if @recipient.present?
                @recepient_type = SmxTransaction.recipient_types[:smx_recep_]
            else
                if @user_country.alpha3 == 'USA' && @recepient_country.alpha3 == 'USA'
                    @recepient_type = SmxTransaction.recipient_types[:non_smx_recep_]
                else
                    @recepient_type = SmxTransaction.recipient_types[:international_recep_]
                end
            end
        end
    end

    def set_exchange_rate
        if @message.count == 0
            puts("#{@user_currency_code} - #{@recepient_currency_code}")
            rate = CurrencyExchange.where('currency_from = ? AND currency_to = ?', @user_currency_code, @recepient_currency_code).last
            if rate.present?
                @exchange_rate = rate.effective_exchange_rate
            else
                @exchange_rate = 0.001
                # @message << "The user is from a different country. We dont support international transactions for your country at this moment." 
            end
        end
    end

    def get_effective_exchange_rate(from_currency, to_currency)
        
    end

    def set_account
        if @message.count == 0
            @user_account = @user.account.profile
            @recipient_account = @recipient.account.profile if @recipient.present?
        end
    end

    def set_fees
        if @message.count == 0
            @fees = 0
        end
    end

    def check_balance 
        if @message.count == 0
            @message << "You dont have enough money for this transaction. Please add money and try again"  if ((@user_account.reload.balance - BigDecimal(@amount)) <= 0.0)
        end
    end

    def create_smx_transaction
        puts "------------------ Create user transaction and smx_transaction entries ------------------"
        user_transaction = UserTransaction.create! net_amount: @amount.to_f, 
                                               fees: @fees, 
                                               exchange_rate: @exchange_rate, 
                                               sender_id: @user.id,
                                               recipient_id: @recipient.id,
                                               country_from: @user.country,
                                               country_to: @recipient.country,
                                               status: @trans_status, 
                                               payment_type: @payment_type,
                                               trans_type: @trans_type

        @smx_transaction = SmxTransaction.create! amount: @amount.to_f + @fees, 
                                              transactionable: user_transaction
        @smx_transaction_id = user_transaction.id
    end

    def create_user_activity
        unless !@amount
            amount  = "#{@amount}"
        end
        puts "------------------ Create user activitys ------------------"
        @user.activities.create! activity: @user_activity,
                             amount: amount,
                             smx_transaction_id: @smx_transaction_id,
                             status: @trans_status
    end

    def create_recipient_activity
        unless !@amount
            amount  = "#{@amount}"
        end
        puts "------------------ Create recipient activity ------------------"
        @recipient.activities.create! activity: @recipient_activity,
                                  amount: amount,
                                  smx_transaction_id: @smx_transaction_id,
                                  status: @trans_status
    end

    def create_recipient_notification
        puts "------------------ Create recipient notification #{@amount} - #{@exchange_rate}------------------"
        send_notification = TransferNotification.create! amount: BigDecimal(@amount.to_s), 
                                                     notice_type: @notice_type,
                                                     smx_transaction_id: @smx_transaction_id, 
                                                     notified_by_id: @user.id

        all = Notification.create! noticeable: send_notification, 
                               notice: @recipient_notice,
                               read: false, 
                               user_id: @recipient.id

        all.send_request_notification
    end
end
