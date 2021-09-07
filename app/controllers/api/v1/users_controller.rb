class Api::V1::UsersController < Api::V1::BaseController 

    def_param_group :user do
        param :user, Hash, required: true, action_aware: true do
            param :amount, Float, required: true, allow_nil: false
            param :recipient_id,Integer, required: true, allow_nil: false
        end
    end

    def index
        render status: 403
        return
        render json: User.all
        #render json: User.all.as_json({only: [:first_name, :telephone, :email]})
    end

    api :GET, '/basic_stats', 'Get basic statistics of Smx Use'
    def basic_stats
        if @user.role == 'admin_' && @api_key == ENV['ADMIN_API_KEY']
            user_count  = User.where(role: :user_).count
            trans_count = UserTransaction.count
            trans_amount = 0 
            render status: 200, json: {status: 200, user_count: user_count, trans_count: trans_count, amount: trans_amount}
        else
            render status: 400, json: {status: 400, error: "Invalid request"}
        end
    end

    api :GET, '/user_list', 'Get list of all users'
    def user_list
        if @user.role == 'admin_' && @api_key == ENV['ADMIN_API_KEY']
            users = User.where(role: :user_).all
            user_list = []
            users.each do |user|
                user_list << {
                    id: user.id,
                    member_since: user.created_at,
                    first_name: user.first_name,
                    last_name: user.last_name,
                    telephone: user.telephone,
                    email: user.email,
                    balance: user.get_formatted_balance
                }
            end
            render status: 200, json: {status: 200, users: user_list}
        else
            render status: 400, json: {status: 400, error: "Invalid request"}
        end 
    end

    api :GET, '/get_user', 'Get data of selected user'
    def get_user
        user_id = params[:user][:user_id]
        telephone_number = params[:user][:telephone]
        
        @existing_user = params.has_key?(:user_id) ? User.find(user_id) : User.find_by(telephone: telephone_number)

        if @existing_user.present?
            country = UserTransaction.new.iso_country @existing_user.country
            user_country = country.blank? ? nil : Country.find_by(iso_alpha_3: country.alpha3)
            avatar_url = @existing_user.picture.avatar.url(:thumb)
            user_data = {
                first_name: @existing_user.first_name.capitalize,
                last_name: @existing_user.last_name.capitalize,
                country: country.blank? ? '' : country.name.capitalize,
                kyc_verified: @existing_user.kyc_verified == true ? 1 : 0,
                country_code: country.present? ? country.country_code : '',
                international_prefix: country.present? ? country.international_prefix : '',
                national_destination_code_lengths: country.present? ? country.national_destination_code_lengths[0] : '',
                national_number_lengths: country.present? ? country.national_number_lengths[0] : '',
                country_flag: user_country.blank? ? "" : user_country.flag.url(:micro),
                avatar_url: avatar_url,
                is_benificiary: UserTransaction.where(sender_id: @user.id, recipient_id: @existing_user.id).count
            }
            render status: 200, json: {status: 200, user_data: user_data}
        else
            render status: 404, json: {status: 404, message: "User not found"}
        end
    end

    #########################################
    #    Find a user
    #########################################
    api :GET, '/find_user', 'find a user'
    def find_user 
        input = params[:input]
        key = "%#{input.downcase}%"
        columns = %w{username email first_name last_name telephone}
        users = User.where(role: User.roles[:user_]).where.not(id: @user.id).where(columns.map {|c| "lower(#{c}) like :search" }.join(' OR '), search: key).uniq

        unless users.present?
            render status: 404, json: {status: 404, message: "Users not found"}
            return
        end 
      
        resp = []
        users.each do |user|
            avatar = get_avatar user
            resp << { id: user.id, 
                avatar:  avatar,
                first_name: user.first_name, 
                last_name: user.last_name,
                telephone: PhonerService.new(user.telephone).format_number,
                username: "#{user.username}"
            }
        end

        render status: 200, json: {status: 200, users: resp}
    end

    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    #    Get user smx contacts
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    api :GET, '/user_smx_contacts', 'user smx contacts'
    def user_smx_contacts
    # Query users based on contact book phone number and email address of user. 
        user_list = User.joins("INNER JOIN contact_books ON users.telephone = contact_books.telephone OR users.email = contact_books.email")
                    .where(contact_books: { smx_user: true, user_id: @user.id})
                    .where.not(telephone: @user.telephone)
                    .where.not(email: @user.email)

        #Set http return status 
        puts user_list.count
        if user_list.count > params[:offset].to_i + params[:count].to_i
            status = 206
        else
            status = 200
        end

        #Order and get the range of users to be returned
        contacts = []
        users = user_list.order("last_name asc, first_name asc").drop(params[:offset].to_i).first(params[:count].to_i)
        users.each do |user|
            ######### This code needs to be removed at deployment. ######################
            ######### It wont be necessary as every new user will  ######################
            ######### have default picture created.                ######################
            avatar = get_avatar user
            #############################################################################
            contacts << { id: user.id, 
                    avatar: avatar, #Picture.where(user_id: user.id ).avatar.url(:square),
                    first_name: user.first_name, 
                    last_name: user.last_name,
                    #telephone: user.telephone,
                    #email: user.email,
                    username: "#{user.username}"
            }
        end

        #Return contact
        if contacts.present?
            render status: status, json: {contacts: contacts}
        else
            render json: { message: "User has not smx contacts"}
        end 
    end

  
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    #    Get user non smx contacts
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    api :GET, '/user_non_smx_contacts', 'user non smx contacts'
    def user_non_smx_contacts
        #Get the smx contacts
        contact_list = @user.contact_books.where(smx_user: false)
        #Set http return status 
        if contact_list.count > params[:offset].to_i + params[:count].to_i
            status = 206
        else
            status = 200
        end
        #Order and get the range of users to be returned
        contacts = contact_list.order("name asc").drop(params[:offset].to_i).first(params[:count].to_i)
        #Return contact
        if contacts.present?
            render status: status, json: {contacts: contacts.as_json({only: [:name, :smx_user, :telephone, :email]})}
        else
            render json: { message: "User has not non-smx contacts"}
        end 
    end

    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    #   Get user smx and non smx contacts <= this is not currently used  
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    api :GET, '/user_contacts', 'user contacts'
    def user_contacts
        #Get the smx contacts
        contact_list = @user.contact_books
        #Set http return status 
        if contact_list.count > params[:offset].to_i + params[:count].to_i
            status = 206
        else
            status = 200
        end
    
        contact_list = contact_list.order("name asc").drop(params[:offset].to_i).first(params[:count].to_i)
        #Create contact list
        contacts = []
        contact_list.each do |c|
            if c[:smx_user] == true
                users = User.where('telephone=? OR email=?', c[:telephone], c[:email])
                users.each do |user|
                    ######### This code needs to be removed at deployment. ######################
                    ######### It wont be necessary as every new user will  ######################
                    ######### have default picture created.                ######################
                    avatar = get_avatar user
                    #############################################################################

                    contacts << { id: user.id, 
                        avatar: avatar, #Picture.where(user_id: user.id ).avatar.url(:square),
                        first_name: user.first_name, 
                        last_name: user.last_name,
                        #telephone: user.telephone,
                        username: "#{user.username}"
                    }
                end
            else
                contacts << {name: c.name, 
                        smx_user:c.smx_user, 
                        telephone: c.telephone, 
                        email: c.email
                }
            end
        end

        #Return contact
        if contacts.present?
            render status: status, json: {contacts: contacts }
        else
            render json: { message: "User has not sync'd contacts"}
        end 
        #render status: status, json: contacts
        #render json: contacts.as_json({only: [:id, :smx_user, :name, :telephone, :email]})
    end

  
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  #    Sync user's contact list to Contact Book table
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  api :POST, '/sync_contacts', 'sync Contacts'
  def sync_contacts
    contacts = params[:user][:contacts]
    
    contacts.each do |contact|
      # @name = contact[:name].strip unless contact[:name] == nil
      # @telephone = contact[:telephone].gsub(/\s+/, "") unless contact[:telephone] == nil
      # @email = contact[:email].strip unless contact[:email] == nil

        @name = contact[:name].strip if contact[:name].present?
        @telephone = contact[:telephone].gsub(/[^0-9A-Za-z]/, '') if contact[:telephone].present?
        @email = contact[:email].strip if contact[:email].present?
      
        next unless @telephone.present? || @email.present?

        if @telephone.present?
            c = ContactBook.where(user_id: @user.id ).where(telephone: @telephone)  
            cc = c.where(email: @email) if @email.present?
            c = cc if cc.present?
        elsif @email.present?
            c = ContactBook.where(user_id: @user.id ).where(email: @email) 
        end

        if c.present?
            c.first.update name: @name,
                       telephone: @telephone,
                       email: @email
            puts "Contact updated"
        else
            cont = ContactBook.create user_id: @user.id,
                               smx_user: false,
                               name: @name,
                               telephone: @telephone,
                               email: @email
            puts "Contact created"
        end

        # This may never get excircised
        if cont.present? && cont.errors.present? #c.errors.full_messages.present?
            @message = "Harmless Error: \n"
            @message += cont.errors.full_messages.to_json + "\n"
            @message += contact.to_json
            log_info
        end
    end 

    #Sync users table with contact_books table
    contacts = ContactBook.joins("INNER JOIN users ON users.telephone = contact_books.telephone OR users.email = contact_books.email")
                          .where(contact_books: { smx_user: false })
    contacts.each do |contact| 
        contact.smx_user = true
        contact.save
    end
  
    #Return completion message
    render json: {message: "User contact sync completed successfully"}
  end

  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  #    Get user profile
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  api :GET, '/profile','Profile'
  param_group :user
  def profile
    @user_profile = @user.as_json(only: [:id, :first_name, :last_name, :username, :telephone, :email, :country, :phone_verified, :email_verified, :stripe_customer_id, :kyc_verified], include: { picture: { only: [:updated_at], methods:[:avatar_url]}})
    
    country = @user.get_country_from_name(@user.country)
    user_country = country.blank? ? nil : Country.find_by(iso_alpha_3: country.alpha3)
    @user_profile["telephone"] = PhonerService.new(@user_profile["telephone"]).format_number
    @user_profile["first_name"] = @user_profile["first_name"].capitalize
    @user_profile["last_name"] = @user_profile["last_name"].capitalize
    @user_profile["country"] = country.present? ? country.alpha3 : ''
    @user_profile["kyc_verified"] = @user_profile["kyc_verified"] == true ? 1 : 0
    @user_profile["country_code"] = country.present? ? country.country_code : ''
    @user_profile["international_prefix"] = country.present? ? country.international_prefix : ''
    @user_profile["national_destination_code_lengths"] = country.present? ? country.national_destination_code_lengths[0] : ''
    @user_profile["national_number_lengths"] = country.present? ? country.national_number_lengths[0] : ''
    @user_profile['country_flag'] = user_country.blank? ? "" : user_country.flag.url(:micro)
    render json:  {profile: @user_profile} 
  end


  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  #    Get user balance
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  api :GET, '/balance','Get user balance'
  def balance 
    #@balance = @user.user_account.balance
    @balance = @user.get_formatted_balance
    render json: { balance: @balance }
  end

  # def send_moneyy
  #   #render json: ISO3166::Country.all
  #   #return
  #   @recipient = User.find_by_id user_params[:recipient_id]
  #   @transaction = TransactionService.new(@user, @recipient, user_params[:amount])
  #   message = @transaction.send_money

  #   ## Actually null is never returned. May not need this check??
  #   if message.nil?
  #     render status: 500, json: {error: "Oops! Something went wrong. Try again later"}

  #   else
  #     if !message.try(:first)[:error].present?
  #       render json: message.first
  #     else
  #       balance = @user.get_formatted_balance
  #       message.try(:first)[:balance] = balance
  #       render json: message.try(:first)
  #     end
  #   end
  # end

  #api :GET, '/profile_picture','List of activities for the users'
  # def profile_picture
  #   user_avatar = @user.avatar.url
  #   if user_avatar.present?
  #     render json: {status: 200, user_avatar: user_avatar }
  #   else 
  #     render json: {status: 200, message: "Image not present" }
  #   end
  # end
  api :GET, '/beneficiaries', 'user beneficiaries'
    def beneficiaries
        @beneficiaries = Array.new
        sent_trans = UserTransaction.where(sender_id: @user.id).order('created_at desc')
        received_trans = UserTransaction.where(recipient_id: @user.id).order('created_at desc')
        total_count = sent_trans.count + received_trans.count
        if total_count > 0
            sent_trans.each do |user_transaction|
                data = user_transaction.beneficiary_data(true)
                if @beneficiaries.select{|b| b[:telephone] == data[:telephone]}.count == 0
                    @beneficiaries << data
                end
            end
            received_trans.each do |user_transaction|
                data = user_transaction.beneficiary_data(false)
                if @beneficiaries.select{|b| b[:telephone] == data[:telephone]}.count == 0
                    @beneficiaries << data
                end
            end
            @list_data = set_status_and_list_limit @beneficiaries
            render status: @status, json: {status: @status, beneficiaries: @list_data, total_count: total_count}
        else
            render status: 200, json: {status: 200, beneficiaries: [], message: "You have no beneficiaries at this moment.", total_count: 0 } 
        end
        
    end

    def receiver_pic receiver_name
        return "#{ENV['LETTER_IMAGES']}/#{receiver_name.first.upcase}_thumb.png"
    end

  private 

  ######### This code needs to be removed at deployment. ######################
  ######### It wont be necessary as every new user will  ######################
  ######### have default picture created.                ######################
  def get_avatar user
    unless user.picture == nil 
      user.picture.avatar.url(:square) 
    end
  end
  #############################################################################


  def user_params
    params.require(:user).permit(:amount,:recipient_id, :input, :contacts)
  end

  def contact_params
    params.require(:user).permit({contacts: []})
  end

  def log_info
    puts "--------------------------------------------------"
    logger.info @message
    puts "--------------------------------------------------" 
  end 

   private

    def set_status_and_list_limit list
        list = list.sort_by{|k, v| k[:created_at]}
        if list.count > params[:offset].to_i + params[:count].to_i
            @status = 206
        else
            @status = 200
        end
        list.drop(params[:offset].to_i).first(params[:count].to_i)
    end

    def format_date date 
        if date >= Time.zone.now.beginning_of_day
            return date.strftime("%H:%M")
        else
            return date.strftime("%d %b")
        end
    end

end
