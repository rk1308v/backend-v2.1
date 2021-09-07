class User < ActiveRecord::Base
    require 'money'
  
    serialize :descriptions, Array
    enum role: [:user_, :agent_, :admin_]
    after_initialize :set_default_role, :if => :new_record?

    devise :database_authenticatable, :registerable, :lockable, :recoverable, :rememberable, :trackable, :validatable

    # Relationship
    has_one :user_account
    has_one :authtoken, dependent: :destroy
    has_many :addresses, dependent: :destroy
    has_many :payment_methods, dependent: :destroy
    #has_many :user_month_to_date, dependent: :destroy
    #has_many :user_year_to_date, dependent: :destroy
    has_many :referral_contacts, dependent: :destroy
    has_many :contact_books, dependent: :destroy
    has_many :user_cards, dependent: :destroy
    has_many :user_charges, dependent: :destroy
    #has_one :contact_book, dependent: :destroy

    has_one :picture, dependent: :destroy
    has_one :account, dependent: :destroy
    has_one :user_account, through: :account, source: :profile, source_type: 'UserAccount'
    has_one :agent_account, through: :account, source: :profile, source_type: 'AgentAccount'

    # has_many :transactions, class_name: 'Transaction', foreign_key: 'originator_id', dependent: :destroy
    # has_many :user_transactions,  through: :transactions, source: :transactionable, source_type: 'UserTransaction'
    # has_many :agent_transactions, through: :transactions, source: :transactionable, source_type: 'AgentTransaction'
    # has_many :admin_transactions, through: :transactions, source: :transactionable, source_type: 'AdminTransaction'
    # has_many :susu_transactions,  through: :transactions, source: :transactionable, source_type: 'SusuTransaction'  
    # has_many :received_user_transactions, class_name: 'UserTransaction', foreign_key: 'recipient_id'
    # has_many :received_agent_transactions, class_name: 'AgentTransaction', foreign_key: 'recipient_id'
    # has_many :received_admin_transactions, class_name: 'AdminTransaction', foreign_key: 'recipient_id'

    # Not needed as we dont normally go through user to find smx_transaction or vice versa
    # has_many :smx_transactions, dependent: :destroy
    # has_many :user_transactions,  through: :smx_transactions, source: :transactionable, source_type: 'UserTransaction'
    # has_many :susu_transactions,  through: :smx_transactions, source: :transactionable, source_type: 'SusuTransaction'
  
    has_many :sender_transactions, class_name: 'UserTransaction', foreign_key: 'sender_id'
    has_many :recipient_transactions, class_name: 'UserTransaction', foreign_key: 'recipient_id'
    has_many :agent_transactions, class_name: 'AgentTransaction', foreign_key: 'agent_id'
    has_many :user_to_agent_transactions, class_name: 'AgentTransaction', foreign_key: 'user_id'
    has_many :susu_transactions, class_name: 'SusuTransaction', foreign_key: 'user_id'
  
    has_many :susu_memberships, dependent: :destroy
    has_many :susus, through: :susu_memberships
    has_many :invitations, class_name: 'SusuInvite', foreign_key: 'recipient_id'
    has_many :sent_invites, class_name: 'SusuInvite', foreign_key: 'sender_id'
    
    has_many :notifications, dependent: :destroy
    has_many :activities, dependent: :destroy  #necessity???

    # validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\z/
    # has_attached_file :avatar,
    #   styles: {micro: '48x48>', preview: '300x300>',  square: '200x200#', thumb: '100x100>' },
    #   s3_permissions: :private,
    #   path: 'images/:class/:attachment/:user_id/:id/:style.:extension',
    #   default_url: 'https://smx-image-bucket.s3-website-us-west-2.amazonaws.com/images/:attachment/default/missing_:style.png'

    # Validations 
    validates :first_name, presence: { message: "is required" }, length: {minimum: 3, maximum:20}
    validates :last_name, presence: { message: "is required" }, length: {minimum: 3, maximum:20}
    validates :email, presence: { message: "is required" }, format: {with: /.+@.+\..+/i }  # {with: Devise::email_regexp or with: /\A.+@.+$\Z/}
    validates :country, presence: { message: "is required" }
    validates :telephone, uniqueness: {allow_blank: true, message: '%{value} is already associated with another account' } #{allow_nil: true, allow_blank: true}
    validates :username, uniqueness: {message: '%{value} is already used. Please try again'}, length: {minimum: 4, maximum:40}
    validate :password_complexity

    has_attached_file :kyc,
                    s3_permissions: :private,
                    path: 'images/:class/:attachment/:id/:parameterize_file_name.:extension'
    
    validates_attachment_content_type :kyc, content_type: /\Aimage\/.*\z/

    def self.parse_kyc_document kyc_document_s
        kyc_document = Paperclip.io_adapters.for(kyc_document_s)
    end

    after_create do
        if !self.telephone.blank?
            phone_number = self.telephone.gsub(/[[:space:]]/, '')
            pending_transactions = UserTransaction.where(status: SmxTransaction.statuses[:pending_], recipient_telephone: phone_number)
            pending_transactions.each do |transaction|
                if transaction.response_hash[:payout_service] == SmxTransaction.const_names[:smx_non_smx_service_name]
                    transaction.update(recipient_id: self.id, recipient_type: SmxTransaction.recipient_types[:smx_recep_])
                    UtsWorker.set(queue: 'smx_transaction_queue').perform_in(1.minute, transaction.id, 'smx_transaction_queue')
                end
            end
        end
    end

    def full_name
        return "#{self.first_name.capitalize} #{self.last_name.capitalize}"
    end

    def self.find_for_database_authentication(warden_conditions)
        conditions = warden_conditions.dup.except(:password)
        if login = conditions.delete(:login)
            where(conditions.to_h).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
        elsif conditions.has_key?(:username) || conditions.has_key?(:email)
            where(email: conditions[:email].downcase).first
        end
    end
    
    def self.send_text_message(number_to_send_to, message)
        SmsService.new(number_to_send_to, message).send_message
    end


    #private

    def set_default_role
        self.role ||= :user_
    end

    def set_agent_role
        self.role = :agent_
    end

    def user_validity_check
        message = nil
        if !self.phone_verified
            message = "You need to verify your phone number"
        elsif !self.email_verified
            message = "You need to verify your email address"
        end
        message
    end

    def validate_email
        self.email_verified = true
        self.email_token = nil
    end

    def set_email_token
        if self.email_token.blank?
            self.email_token = SecureRandom.urlsafe_base64.to_s
        end
    end

    def get_formatted_balance
        balance = get_balance
        country = self.country
        format_amount(balance, country)
        return {amount: '%.2f' % balance.to_f, currency: @currency.upcase, symbol: @symbol, currency_first: @currency_first}
    end

    def get_formatted_amount_display(amount)
        country = self.country
        format_amount(amount, country)
        return {amount: '%.2f' % amount.to_f, currency: @currency.upcase, symbol: @symbol, currency_first: @currency_first}
    end

    def get_formatted_amount(amount, country)
        format_amount(amount, country)
        return "#{@formatted_amount} #{@currency.upcase}"
    end


    def set_limits
        account = self.account.profile
        account.single_send_limit = 100
        account.self.account.profile.monthtly_send_limit = 1000
        account.save!
    end 

    def error_message
        if self.errors.include?(:country)
            message  = self.errors.full_messages_for(:country).first 
        elsif self.errors.include?(:first_name)
            message  = self.errors.full_messages_for(:first_name).first
        elsif self.errors.include?(:last_name)
            message  = self.errors.full_messages_for(:last_name).first
        elsif self.errors.include?(:email)
            message  = self.errors.full_messages_for(:email).first
        elsif self.errors.include?(:password)
            message  = self.errors.full_messages_for(:password).first
        elsif self.errors.include?(:password_confirmation)
            message  = self.errors.full_messages_for(:password_confirmation).first
        elsif self.errors.include?(:telephone)
            message  = self.errors.full_messages_for(:telephone).first
        elsif self.errors.full_messages_for(:username).first
            message = self.errors.full_messages_for(:username).first
        else 
            message  = self.errors.full_messages
        end
    end

    def get_country_from_phone
        if self.telephone.blank?
            return nil
        else
            phone_number = "+#{self.telephone}"
            is_valid = Phoner::Phone.valid? phone_number
            if is_valid
                country_code = Phoner::Phone.parse(phone_number).country_code
                iso_country = ISO3166::Country.find_country_by_country_code(country_code)
                if iso_country.blank?
                    return nil
                else
                    return Country.last.iso_alpha_3
                end
            else
                return nil
            end
        end
    end

    def get_country_from_name(country_name)
        country = ISO3166::Country.find_country_by_alpha3(country_name)
        if country.nil?
            country = ISO3166::Country.find_country_by_name(country_name)
        end
        return country
    end

    def get_currency(country_name)
        puts "country: #{country}"
        country = ISO3166::Country.find_country_by_alpha3(country_name)
        if country.blank?
            country = ISO3166::Country.find_country_by_name(country_name)
        end
        country.currency_code.upcase
    end

    # def resize_images
    #     dire_path = '/Users/amolaher/Desktop/pngs'
    #     exp_path = '/Users/amolaher/Desktop'
    #     imgs = Dir.entries(dire_path).select {|f| !File.directory? f}
    #     imgs.each do |im|
    #         cap_initial_name = im[0]
    #         down_initial_name = im[0].downcase
    #         puts "#{cap_initial_name} - #{down_initial_name}"
    #         image = Magick::Image.read("#{dire_path}/#{im}").first

    #         micro = image.resize_to_fit(48, 48) 
    #         preview = image.resize_to_fit(300, 300) 
    #         thumb = image.resize_to_fit(100, 100) 
    #         square = image.resize_to_fit(200, 200) 

    #         # micro.write("#{exp_path}/resized/#{cap_initial_name}_micro.png")
    #         micro.write("#{exp_path}/resized/#{down_initial_name}_micro.png")

    #         # preview.write("#{exp_path}/resized/#{cap_initial_name}_preview.png")
    #         preview.write("#{exp_path}/resized/#{down_initial_name}_preview.png")

    #         # thumb.write("#{exp_path}/resized/#{cap_initial_name}_thumb.png")
    #         thumb.write("#{exp_path}/resized/#{down_initial_name}_thumb.png")

    #         # square.write("#{exp_path}/resized/#{cap_initial_name}_square.png")
    #         square.write("#{exp_path}/resized/#{down_initial_name}_square.png")
    #     end
    # end

    private

    def get_balance
        self.account.profile.reload.balance
    end

    def format_amount(amount, country_name)
        puts "country: #{country}"
        amount = BigDecimal(amount.to_s)
        country = ISO3166::Country.find_country_by_alpha3(country_name)
        if country.blank?
            country = ISO3166::Country.find_country_by_name(country_name)
        end
        @symbol = country.currency.symbol
        @currency = country.currency_code
        @currency_first = country.currency.symbol_first
        # @formatted_amount = Money.new(amount.to_f * 100.0, country.currency_code).format(symbol: false)
        @formatted_amount = Money.from_amount(amount.to_f, country.currency_code).format(symbol: false)
    end

    def password_complexity
        if password.present? and not password.match(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/)
            errors.add :password, "must include at least one lowercase letter, one uppercase letter, one digit and one special character"
        end
    end

end
