class UserTransaction < ApplicationRecord
    # include GlobalEnums
    serialize :descriptions, Array
    serialize :response_hash
    
    # Relationships
    belongs_to :sender, class_name: 'User'
    belongs_to :recipient, class_name: 'User', optional: true
    belongs_to :payment_service, class_name: 'PaymentService'
    belongs_to :payment_organisation, class_name: 'PaymentOrganisation'

    has_many :smx_transactions, as: :transactionable
    has_many :transfer_notifications

    # Validations
    validates :net_amount, presence: true
    validates :fees, presence: true
    validates :exchange_rate, presence: true
    validates :country_from, presence: true
    validates :country_to, presence: true
    # validates :status, presence: true, inclusion: { in: 0..2, message: "%{value} is not a valid status"}
    #validates :trans_type, presence: true, inclusion: { in: %w(send_ request_), message: "%{value} is not a valid trans_type"}
    validates :trans_type, presence: true, inclusion: { in: 0..1, message: "%{value} is not a valid trans_type"}
    #validates :payment_type, presence: true, inclusion: { in: %w(smx_ electronic_), message: "%{value} is not a valid payment_type"}
    validates :payment_type, presence: true, inclusion: { in: 0..3, message: "%{value} is not a valid payment_type"}
    validates :sender_id, presence: true
    validates :recipient_id, presence: true, :unless => :recipient_telephone?

    before_save do
        if self.id.present?
            resp_hash = self.response_hash
            resp_hash[:transaction_status] = self.transaction_status

            status_job_id = self.status_worker_job_id
            job = Sidekiq::ScheduledSet.new.find_job([status_job_id])
            if job
                job.delete
            end
            if self.status == SmxTransaction.statuses[:pending_]
                if self.recipient_type == SmxTransaction.recipient_types[:international_recep_]
                    job_id = TransactionStatusWorker.set(queue: 'transaction_status_queue').perform_in(DateTime.now + 1.day, self.id)
                    self.status_worker_job_id = job_id
                elsif self.recipient_type == SmxTransaction.recipient_types[:non_smx_recep_]
                    job_id = TransactionStatusWorker.set(queue: 'transaction_status_queue').perform_in(DateTime.now + 5.day, self.id)
                    self.status_worker_job_id = job_id
                end
            end
        end
    end

    def iso_currency(country_name)
        country = ISO3166::Country.find_country_by_alpha3(country_name)
        if country.nil?
            country = ISO3166::Country.find_country_by_name(country_name)
        end
        return country.nil? ? '' : country.currency.symbol
    end

    def iso_country(country_name)
        country = ISO3166::Country.find_country_by_alpha3(country_name)
        if country.nil?
            country = ISO3166::Country.find_country_by_name(country_name)
        end
        return country
    end
    
    def transaction_status
        if self.status == SmxTransaction.statuses[:pending_]
            return 'Pending'
        elsif self.status == SmxTransaction.statuses[:cancelled_]
            return 'Cancelled'
        elsif self.status == SmxTransaction.statuses[:completed_]
            return 'Completed'
        elsif self.status == SmxTransaction.statuses[:queued_]
            return 'Queued'
        end
    end

    def refund_charge
        if self.stripe_charge.present?
            @amount = (self.net_amount * self.exchange_rate) * 100
            refund = Stripe::Refund.create({
                charge: self.stripe_charge,
                amount: @amount.to_i
            })
            if refund
                self.update(stripe_charge: '')
            end
        end
    end

    def detect_payment_service
        iso_country = iso_country(self.country_to)
        segovia_supported_countries = ['UGX', 'KES', 'GHS', 'TZS']
        transferto_supported_countries = []
        if iso_country.blank?
            return nil
        else
            if segovia_supported_countries.include? iso_country.currency.iso_code
                return PaymentService.find_by(service_name: SmxTransaction.const_names[:segovia_service_name])
            # elsif transferto_supported_countries.include? iso_country.currency.iso_code
            #     return PaymentService.find_by(service_name: SmxTransaction.const_names[:transfer_to_service_name])
            else
                return nil
            end
        end
    end

    def formatted_time
        if self.created_at >= Time.zone.now.beginning_of_day
            return self.created_at.strftime("%H:%M")
        else
            return self.created_at.strftime("%d %b")
        end
    end

    def receiver_pic receiver_name
        return "#{ENV['LETTER_IMAGES']}/#{receiver_name.first.upcase}_thumb.png"
    end

    def beneficiary_data(is_sender)
        telephone = is_sender ? (self.recipient.present? ? self.recipient.telephone : self.response_hash[:recipient_telephone]) : self.sender.telephone
        formatted_telephone = PhonerService.new(telephone).format_number
        data = Hash.new
        data[:id] = is_sender ? (self.recipient.present? ? self.recipient_id : '') : self.sender_id
        data[:recipient_name] = is_sender ? (self.recipient.present? ? self.recipient.full_name.to_s.titlecase : self.response_hash[:recipient_name].to_s.titlecase) : self.sender.full_name.to_s.titlecase
        data[:first_name] = is_sender ? (self.recipient.present? ? self.recipient.first_name.to_s.titlecase : self.response_hash[:recipient_first_name].to_s.titlecase) : self.sender.first_name.to_s.titlecase
        data[:last_name] = is_sender ? (self.recipient.present? ? self.recipient.last_name.to_s.titlecase : self.response_hash[:recipient_last_name].to_s.titlecase) : self.sender.last_name.to_s.titlecase
        data[:avatar] = is_sender ? (self.recipient.present? ? self.recipient.picture.avatar.url(:thumb) : self.receiver_pic(self.response_hash[:recipient_name])) : self.sender.picture.avatar.url(:thumb)
        data[:telephone] = formatted_telephone
        data[:created_at] = self.created_at
        data[:username] = is_sender ? (self.recipient.present? ? self.recipient.username : '') : self.sender.username
        data[:sender_name] = is_sender ? (self.recipient.present? ? self.recipient.full_name.titlecase : self.response_hash[:recipient_name]) : self.sender.full_name.titlecase
        return data
    end

    def recipient_account
        case self.recipient_type
        when SmxTransaction.recipient_types[:smx_recep_]
            return 'SMX'
        when SmxTransaction.recipient_types[:non_smx_recep_]
            return 'Non SMX'
        when SmxTransaction.recipient_types[:international_recep_]
            return 'International'
        else
            return 'SMX'
        end
    end

    def message_status(requesting_user)
        if self.status == SmxTransaction.statuses[:pending_]
            return 'Your payment is on its way'
        elsif self.status == SmxTransaction.statuses[:cancelled_]
            if self.recipient_type == SmxTransaction.recipient_types[:non_smx_recep_]
                return 'Your recipient did not respond to our request. Please ask recipient to download Smx app and try again.'
            elsif self.recipient_type == SmxTransaction.recipient_types[:international_recep_]
                return 'We were not able to deliver the funds. The destination platform may be down. You may try again later.'
            else
                return 'Your payment could not be processed. Please try again later'
            end
        elsif self.status == SmxTransaction.statuses[:completed_]
            if requesting_user.id == self.sender_id
                return 'Your payment was sent successfully'
            else
                return "#{self.sender.first_name} #{self.sender.last_name} paid you #{self.net_amount.to_f} #{self.iso_currency(self.country_to)}"
            end
        elsif self.status == SmxTransaction.statuses[:queued_]
            return 'Your payment is queued'
        end
    end

    def payout_service_fees
        return 0.00
    end

    def summary(requesting_user)
        @user = self.sender
        recipient_telephone = self.recipient.present? ? self.recipient.telephone : self.response_hash[:recipient_telephone]
        @user_country = UserTransaction.new.iso_country(@user.country)
        @recipient = self.recipient
        @recipient_country = nil
        if @recipient.present?
            @recipient_country = UserTransaction.new.iso_country(@recipient.country)
        end

        params = {
                    recipient_first_name: self.response_hash[:recipient_first_name], 
                    recipient_last_name: self.response_hash[:recipient_last_name], 
                    recipient_id: self.recipient.present? ? self.recipient.id : 0, 
                    recipient_telephone: recipient_telephone, 
                    amount: self.net_amount.to_f, 
                    user_country: @user.country, 
                    recipient_country: @recipient.present? ? @recipient.country : '', 
                    payout_service: self.payout_service, 
                    payment_method: self.payment_method,
                    transaction_status: self.transaction_status, 
                    sender_user_name: @user.username, 
                    receiver_user_name: @recipient.present? ? @recipient.username : '', 
                    transaction_id: self.id, 
                    recipient_account: self.recipient_account, 
                    fees: self.fees.to_f,
                    payment_processor_fees: self.payment_processor_fees, 
                    payout_service_fees: self.payment_organisation.blank? ? 0.0 : self.payment_organisation.payout_service_fees, 
                    exchange_rate: self.exchange_rate.to_f == 0 ? 1 : self.exchange_rate.to_f,
                    payment_processor_fees_percentage: self.payment_processor_fees_percentage.to_f
                }
        return self.setup_response(params, self.id, self.sender, requesting_user)
    end

    def setup_response(params, user_transaction_id, sender, requesting_user)
        puts params
        user_transaction = user_transaction_id > 0 ? UserTransaction.find(user_transaction_id) : nil
        @user = sender
        @user_country = UserTransaction.new.iso_country(@user.country)
        @recipient = User.find_by(id: params[:recipient_id])
        @recipient_country = nil
        if @recipient.present?
            @recipient_country = UserTransaction.new.iso_country(@recipient.country)
        end

        recipient_telephone = @recipient.present? ? @recipient.telephone : params[:recipient_telephone]
        pn = nil
        ph_no = "+#{recipient_telephone.gsub('+', '')}" if recipient_telephone.present?
        if Phoner::Phone.valid? ph_no
            pn = Phoner::Phone.parse(ph_no)
            @recipient_country = PhonerService.new(ph_no).detect_country
        end

        sender_country = @user_country
        receiver_country = @recipient_country
        
        sender_currency = sender_country.blank? ? '' : sender_country.currency.iso_code
        receiver_currency = receiver_country.blank? ? '' : receiver_country.currency.iso_code

        amount = @user.get_formatted_amount(params[:amount], @user_country.name)
        exchange_rate = params[:exchange_rate].to_f
        amount_received = @user.get_formatted_amount(params[:amount].to_f * exchange_rate , @recipient_country.name)
        fees = @user.get_formatted_amount(params[:fees].to_f, @user_country.name)
        payment_processor_fees = @user.get_formatted_amount(params[:payment_processor_fees].to_f, @user_country.name)
        total_amount = @user.get_formatted_amount((params[:amount].to_f + params[:fees].to_f + params[:payment_processor_fees]).to_f, @user_country.name)


        return {
            status: 200,
            id: user_transaction_id,
            recipient_first_name: params[:recipient_first_name],
            recipient_last_name: params[:recipient_last_name],
            recipient_name: "#{params[:recipient_first_name].capitalize} #{params[:recipient_last_name].capitalize}",
            recipient_id: params[:recipient_id],
            recipient_telephone: PhonerService.new(params[:recipient_telephone]).format_number,
            amount: amount,
            exchange_rate: params[:exchange_rate].to_f > 1.0 ? "1 #{sender_currency} -> #{params[:exchange_rate].to_f} #{receiver_currency}" : params[:exchange_rate].to_f,
            amount_received: amount_received,
            fees: {
                smx_fees: fees,
                payment_processor_fees: payment_processor_fees,
                payout_service_fees: @user.get_formatted_amount(params[:payout_service_fees], @user_country.name)
            },
            payment_processor_fees_percentage: params[:payment_processor_fees_percentage].to_f,
            user_country: @user_country.alpha3,
            recipient_country: @recipient_country.alpha3,
            payout_service: params[:payout_service],
            payment_method: params[:payment_method],
            total_amount: total_amount,
            transaction_status: params[:transaction_status],
            sender_user_name: params[:sender_user_name],
            receiver_user_name: params[:receiver_user_name],
            transaction_id: user_transaction_id,
            currency_symbol: UserTransaction.new.iso_currency(params[:user_country]),
            sender_name: @user.full_name,
            transaction_date: user_transaction.blank? ? '' : user_transaction.created_at,
            recipient_account: params[:recipient_account],
            message: user_transaction.blank? ? '' : user_transaction.message_status(requesting_user)
        }
    end

end
