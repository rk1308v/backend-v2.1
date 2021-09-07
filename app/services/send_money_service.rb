class SendMoneyService
    require "uri"

    def initialize(user, params)
    	@user = user
    	@params = params
    	@amount = params[:amount].to_s
    	@description = params[:description]
    	@recipient_telephone = params.has_key?(:recipient_telephone) ? params[:recipient_telephone].gsub(/[^0-9A-Za-z]/, '') : ''
    	@is_confirmed = params[:is_confirmed].to_i
    	@recipient_id = params[:recipient_id].to_i
    	@payment_method = params[:payment_method].to_i
    	@card_type = params.has_key?(:card_type) ? params[:card_type] : ''
    	@payment_method_number = params.has_key?(:payment_method_number) ? params[:payment_method_number] : ''
    	@source_token = params[:source_token]
        
    	@message = []
    	@code = ''
    	@recipient = @recipient_id > 0 ? User.find(@recipient_id) : nil
        if @recipient.blank?
            @recipient = User.find_by_telephone(@recipient_telephone)
        end

        if @recipient.present?
            @recipient_telephone = @recipient.telephone
        end

        @recipient_first_name = @recipient.present? ? @recipient.first_name : params[:first_name].blank? ? '' : params[:first_name]
        @recipient_last_name = @recipient.present? ? @recipient.last_name : params[:last_name].blank? ? '' : params[:last_name]

    	@notice_type = TransferNotification.notice_types[:send_]
        @trans_status = SmxTransaction.statuses[:pending_]
        @payment_type = @payment_method
        @trans_type = SmxTransaction.trans_types[:send_]
        @transaction_id = SecureRandom.uuid

        check_params
        check_user
    	check_recipient
    	check_user_country
    	check_recipient_country
    	set_recepient_type
        detect_payout_service
    	set_currencies
    	set_exchange_rate
    	set_accounts
    	set_fees
    	set_payment_processor_fees
    	set_total_amount
    	amount_received
    	charge_customer_if_needed
    	check_balance_if_needed
    end

    def send_money
    	if @message.count == 0
    		if @exchange_rate > 0.0
    			if @is_confirmed == 0
    				@response_message = response_hash
    			else
                    resp_hash = response_hash
    				@user_transaction = UserTransaction.create! net_amount: to_bigdecimal(@amount), 
                                        fees: @fees, 
                                        exchange_rate: @exchange_rate, 
                                        sender_id: @user.id,
                                        recipient_id: @recipient.blank? ? nil : @recipient.id,
                                        country_from: @user_country,
                                        country_to: @recipient_country,
                                        status: @trans_status, 
                                        payment_type: @payment_type,
                                        trans_type: @trans_type,
                                        recipient_telephone: @recipient_telephone.blank? ? '' : @recipient_telephone,
                                        recipient_type: @recipient_type,
                                        response_hash: resp_hash,
                                        description: @description,
                                        stripe_charge: @charge.blank? ? '' : @charge.id,
                                        payment_processor_fees: @payment_processor_fees,
                                        payment_processor_fees_percentage: payment_processor_fees_percentage,
                                        payout_service: payout_service_name,
                                        payment_method: payment_method,
                                        transaction_id: @transaction_id,
                                        payment_organisation_id: @payout_service.blank? ? nil : @payout_service.id,
                                        payment_service_id: 1 # This payment_service_id need to investigate (Anand)
                    
                    if @user_transaction
                        create_sender_activity
                        create_reciever_activity
                        if @recipient.present?
                            puts('Paying internally')
                            return pay_internal
                        else
                            if @recipient_type == SmxTransaction.recipient_types[:non_smx_recep_]
                                @user_transaction.save
                                return { status: 200, message: "Your transaction is pending", summary: @user_transaction.summary(@user), balance: @user_account.balance}
                            else
                                payment_service = @user_transaction.detect_payment_service
                                if payment_service.blank?
                                    @user_transaction = nil
                                    puts 'Line: 98'
                                    log_data('Destination country of your transaction is not supported at the moment', 412)
                                    return {status: 412, message: "Destination country of your transaction is not supported at the moment", time_stamp: Time.now.to_i}
                                else
                                    @user_transaction.payment_service = payment_service
                                    @user_transaction.save
                                    pay_data = @user_transaction.payment_service.pay(@user_transaction.id)
                                    if pay_data[:status] == 200
                                        return pay_data
                                    else
                                        log_data('Something went wrong. Try again later.', 412)
                                        return { status: 412, error: "Something went wrong. Try again later."}
                                    end
                                end
                            end
                        end
                    else
                    	log_data('Something went wrong. Try again later.', 412)
                        return { status: 412, error: "Something went wrong. Try again later."}
                    end
    			end
    		else
                puts 'Line: 120'
    			log_data('Destination country of your transaction is not supported at the moment', 412)
                @response_message = {status: 412, message: "Destination country of your transaction is not supported at the moment", time_stamp: Time.now.to_i}
    		end
    	else
            puts "@exchange_rate: #{@exchange_rate}"
            puts "@recipient_country: #{@user_country} - #{@recipient_country}"
            puts "@message: #{@message}"
    		@response_message = { status: 412, code: @code, error: @message.first }
    	end
    	return @response_message
    end

    private

    def payment_method
        if @payment_method == SmxTransaction.payment_types[:smx_account_]
            return SmxTransaction.const_names[:smx_payout_service_name]
        else
            return "#{@card_type} #{@payment_method_number}"
        end
    end

    def payment_processor_fees_percentage
        if @payment_method == SmxTransaction.payment_types[:smx_account_]
            return "0"
        elsif @payment_method == SmxTransaction.payment_types[:card_]
            return "#{card_fee}"
        elsif @payment_method == SmxTransaction.payment_types[:bank_]
            return "#{bank_fee}"
        else
            return "0"
        end
    end

    def payout_service_name
        if @recipient_type == SmxTransaction.recipient_types[:smx_recep_]
            return SmxTransaction.const_names[:smx_payout_service_name]
        elsif @payout_service.present? 
            return @payout_service.name
        else
            return ''
        end
    end

    def recipient_account
        case @recipient_type
        when SmxTransaction.recipient_types[:smx_recep_]
            return 'SMX Account'
        when SmxTransaction.recipient_types[:non_smx_recep_]
            return 'Non SMX'
        when SmxTransaction.recipient_types[:international_recep_]
            return 'International'
        else
            return 'SMX Account'
        end
    end

    def pay_internal
        service_params = {total_amount: @total_amount, user_id: @user.id, recipient_id: @recipient.id, user_transaction_id: @user_transaction.id}
        response = PaymentProcessorService.new(service_params, SmxTransaction.payment_types[:smx_account_]).process_payment
        puts response
        if response[:status] == 200
            update_activities
        end
        return response
    end

    def update_activities
        sender_activity = @user.activities.where(smx_transaction_id: @user_transaction.id).last
        recepient_activity = @recipient.activities.where(smx_transaction_id: @user_transaction.id).last
        @user_transaction.update(status: SmxTransaction.statuses[:completed_])

        if sender_activity.present?
            sender_activity.update(status: SmxTransaction.statuses[:completed_])
        end

        if recepient_activity.present?
            recepient_activity.update(status: SmxTransaction.statuses[:completed_])
        end
    end

    def response_hash
        pn = nil
        ph_no = "+#{@recipient_telephone}" if @recipient_telephone.present?
        if Phoner::Phone.valid? ph_no
            pn = Phoner::Phone.parse(ph_no)
        end

        f_name = @recipient_first_name.blank? ? (@recipient.blank? ? @recipient_telephone : @recipient.first_name) : @recipient_first_name
        l_name = @recipient_last_name.blank? ? (@recipient.blank? ? @recipient_telephone : @recipient.last_name) : @recipient_last_name
            
        params = {recipient_first_name: f_name, recipient_last_name: l_name, recipient_id: @recipient_id, recipient_telephone: @recipient_telephone, amount: @amount, user_country: @user_country.name, recipient_country: @recipient_country.name, payout_service: payout_service_name, payment_method: payment_method, transaction_status: @trans_status, sender_user_name: @user.username, receiver_user_name: @recipient.present? ? @recipient.username : '', transaction_id: @transaction_id, recipient_account: recipient_account, fees: @fees, payment_processor_fees: @payment_processor_fees, payout_service_fees: @payout_service.blank? ? 0.0 : @payout_service.payout_service_fees, exchange_rate: @exchange_rate, payment_processor_fees_percentage: payment_processor_fees_percentage.to_f}
        return UserTransaction.new.setup_response(params, 0, @user, @user)
    end

    def log_data(message, error_code)
    	LogService.new(@params, message, error_code).fatal
		UserMailer.trans_error_email(@params, message).deliver_now
    end

    def check_params
        if @message.count == 0
            if @payment_method > 0
                if @card_type.blank? || @payment_method_number.blank? || @source_token.blank?
                    @message << 'Card/bank details not provided. Parameters incomplete'
                end
            end
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
                if @recipient_telephone.blank?
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

    def check_user_country
    	if @message.count == 0
    		@user_country = UserTransaction.new.iso_country(@user.country)
            puts 'Line: 286'
    		@message << 'Destination country of your transaction is not supported at the moment' if @user_country.blank?
    	end
    end

    def check_recipient_country
    	if @message.count == 0
    		if @recipient.present?
    			@recipient_country = UserTransaction.new.iso_country(@recipient.country)
                puts 'Line: 295'
    			@message << 'Destination country of your transaction is not supported at the moment' if @recipient_country.blank?
    		elsif @recipient_telephone.present?
    			ph_no = "+#{@recipient_telephone.gsub('+', '')}"
    			if Phoner::Phone.valid? ph_no
                    @recipient_country = PhonerService.new(ph_no).detect_country
                end
                puts 'Line: 302'
                @message << 'Destination country of your transaction is not supported at the moment' if @recipient_country.blank?
    		else
                puts 'Line: 305'
    			@message << 'Destination country of your transaction is not supported at the moment'
    		end
    	end
    end

    def detect_payout_service
        if @message.count == 0
            country = Country.find_by(name: @recipient_country.name)
            if country.blank?
                puts 'Line: 315'
                @message << 'Destination country of your transaction is not supported at the moment'
            else
                if @recipient.blank?
                    if @recipient_type == SmxTransaction.recipient_types[:non_smx_recep_]
                        @payout_service = PaymentOrganisation.where(service_name: SmxTransaction.const_names[:smx_non_smx_service_name], availability: 'Live').last
                    else
                        #TODO: We need to break this logic in diffent method. Ex. Like get valid organisations.   
                        org_list = country.payment_organisations.where(availability: 'Live').where.not(min_commission: nil)
                        if org_list.count > 0
                            segovia_list = org_list.where(service_name: SmxTransaction.const_names[:segovia_service_name])
                            transferto_list = org_list.where(service_name: SmxTransaction.const_names[:transfer_to_service_name], termination_type: 0)
                            if segovia_list.count > 0
                                @payout_service = segovia_list.max{|a, b| b.min_commission <=> a.min_commission}
                            elsif transferto_list.count > 0
                                @payout_service = transferto_list.max{|a, b| b.min_commission <=> a.min_commission}
                            else
                                puts 'Line: 331'
                                @message << 'Destination country of your transaction is not supported at the moment'
                            end
                        elsif @recipient_type != SmxTransaction.recipient_types[:international_recep_]
                            @payout_service = PaymentOrganisation.where(service_name: SmxTransaction.const_names[:smx_service_name], availability: 'Live').last
                            if @payout_service.blank?
                                puts 'Line: 337'
                                @message << 'Destination country of your transaction is not supported at the moment'
                            end
                        else
                            puts 'Line: 341'
                            @message << 'Destination country of your transaction is not supported at the moment'
                        end
                    end
                else
                    @payout_service = PaymentOrganisation.where(service_name: SmxTransaction.const_names[:smx_service_name], availability: 'Live').last
                    if @payout_service.blank?
                        puts 'Line: 348'
                        @message << 'Destination country of your transaction is not supported at the moment'
                    end
                end
            end
        end
    end

    def set_recepient_type
    	if @message.count == 0
            if @recipient.present? || User.find_by_telephone(@recipient_telephone)
                @recipient_type = SmxTransaction.recipient_types[:smx_recep_]
            else
                if @user_country.alpha3 == 'USA' && @recipient_country.alpha3 == 'USA'
                    @recipient_type = SmxTransaction.recipient_types[:non_smx_recep_]
                else
                    @recipient_type = SmxTransaction.recipient_types[:international_recep_]
                end
            end
        end
    end

    def set_currencies
    	if @message.count == 0
    		@user_currency_code = @user_country.currency.iso_code
    		@recipient_currency_code = @recipient_country.currency.iso_code
            puts 'set_currencies'
    	end
    end

    def set_exchange_rate
        if @message.count == 0
            if @recipient.blank?
                rate = CurrencyExchange.where('currency_from = ? AND currency_to = ?', @user_currency_code, @recipient_currency_code).last
                if rate.present?
                    @exchange_rate = rate.effective_exchange_rate > 0 ? rate.effective_exchange_rate : rate.value.to_f
                elsif @recipient_type != SmxTransaction.recipient_types[:international_recep_]
                    @exchange_rate = 1.0
                else
                    puts "set_exchange_rate: #{@user_currency_code} - #{@recipient_currency_code}"
                    puts 'Line: 388'
                    @message << 'Destination country of your transaction is not supported at the moment'
                end
            else
                @exchange_rate = 1.0
                puts "Here: #{@recipient} - #{@exchange_rate.to_f}"
            end
        end
    end

    def set_accounts
    	if @message.count == 0
    		@user_account = @user.account.profile
            @recipient_account = @recipient.account.profile if @recipient.present?
    	end
    end

    def set_fees
    	if @message.count == 0
            @fees = "0"
        end
    end

    def card_fee
        return "3"
    end

    def bank_fee
    	return "1"
    end

    def set_payment_processor_fees
    	if @message.count == 0
            if @payment_method == 1
                @payment_processor_fees = (to_bigdecimal(@amount) / to_bigdecimal("100")) * to_bigdecimal(card_fee)
            elsif @payment_method == 2
            	@payment_processor_fees = (to_bigdecimal(@amount) / to_bigdecimal("100")) * to_bigdecimal(bank_fee)
            else
                @payment_processor_fees = to_bigdecimal("0")
            end
        end
    end    

    def to_bigdecimal(amount)
    	return BigDecimal(amount)
    end

    def set_total_amount
    	if @message.count == 0
    		@total_amount = to_bigdecimal(@amount) + to_bigdecimal(@fees) + @payment_processor_fees
        end
    end

    def amount_received
    	if @message.count == 0
    		@amount_received = to_bigdecimal(@amount) * @exchange_rate
    	end
    end

    def charge_customer_if_needed
    	if @message.count == 0 && @is_confirmed == 1
            if @amount.to_f >= 0.5
                if @user.stripe_customer_id.present? && @source_token.present? && @payment_method > 0
                    service_params = {amount: @amount_received.to_i * 100, source: @source_token, currency: @user_currency_code, customer: @user.stripe_customer_id}
                    response = PaymentProcessorService.new(service_params, SmxTransaction.payment_types[:card_]).process_payment
                    puts response
                    if response.present?
                        @user_account.update!(balance: @user_account.reload.balance + BigDecimal(@amount.to_s))
                        @user.user_charges.create(charge_token: response['id'])
                    else
                        @message << "There was a problem charging source. Please try again"
                    end
                else
                    if @payment_method > 0
                        @message << "There was a problem charging source. Please try again"
                    end
                end
            else
                @message << "Amount should be greater than 50 Cents if using card or bank account"
            end
    	end
    end

    def check_balance_if_needed
    	if @message.count == 0
    		if @payment_method == SmxTransaction.payment_types[:smx_account_]
    			if (@user_account.reload.balance - @amount_received <= 0.0)
    				@message << "You dont have enough money for this transaction. Please add money and try again"
    			end
    		end
    	end
    end

    def create_sender_activity
        if @message.count == 0
            @user.activities.create! activity: "#{@user.get_formatted_amount(@amount, @user_country.name)} sent to #{@recipient_first_name} #{@recipient_last_name}", 
                                amount: @amount, 
                                smx_transaction_id: @user_transaction.id, 
                                status: @trans_status
        end
    end

    def create_reciever_activity
        if @message.count == 0
            if @recipient.present?
                @activity = @recipient.activities.create! activity: "#{@user.get_formatted_amount(@amount, @recipient_country.name)} received from #{@user.full_name}", 
                                    amount: @amount,
                                    smx_transaction_id: @user_transaction.id, 
                                    status: @trans_status
                                    
                if @activity.present?
                    @activity.send_receiver_notification
                end
            end
        end
    end

end