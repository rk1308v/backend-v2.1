class Api::V1::Users::RegistrationsController < Api::V1::BaseController
    skip_before_action :authenticate_user_from_token!, :only => [:create_admin, :create, :confirm_email, :validate_signup_params, :validate_username, :telephone_verification, :telephone_verification_update, :password_update_form, :update_password] #[:create, :verify_phone_number]
    skip_before_action :validate_api_key, :only => [:confirm_email, :password_update_form, :update_password] #only: [:validate_signup_params, :telephone_verification, :create]
    after_action :set_access_control_headers, only: [:update_password]

    def set_access_control_headers
        headers['Access-Control-Allow-Origin'] = "*"
        headers['Access-Control-Request-Method'] = %w{GET POST OPTIONS}.join(",")
    end

    def_param_group :user do
        param :user, Hash, action_aware: true do
            param :email, String, required: true
            param :first_name, String, required: true
            param :last_name, String, required: true
            param :username, String, required: true
            param :password, String, required: true
            param :password_confirmation, String, required: true
        end
        param :device_id, String, required: true
    end

    def_param_group :admin do
        param :user, Hash, action_aware: true do
            param :email, String, required: true
            param :first_name, String, required: true
            param :last_name, String, required: true
        end
    end

    ####################################################################
    # # # # #       Registration procedure - PRE - TOKEN       # # # # # 
    ####################################################################

    ####################################################
    # 1. Validate signup params
    ####################################################
    api :POST, '/validate_signup_params', 'validate signup params'
    param_group :user
    error :code => 400, :desc => "Various validation messages"
    def validate_signup_params
        @message = Country.validate_country signup_parameters[:country]
        if @message
            LogService.new(signup_parameters, @message, 400).fatal
            render status: 400, json: {status: 400, error: @message }
            return
        end
        if signup_parameters.has_key?(:date_of_birth)
            dt = Date.parse(signup_parameters[:date_of_birth])
            now_dt = Date.today
            diff = ((now_dt - dt) / 365).floor
            if diff < 18
                render status: 400, json: {status: 400, error: 'You should be at least 18 years old to join Smx' }
                return    
            end
        else
            render status: 400, json: {status: 400, error: 'Birth date is required' }
            return
        end
        @user = User.new signup_parameters
        if @user.invalid? && (@user.errors[:first_name].any? || 
                          @user.errors[:last_name].any? ||
                          @user.errors[:email].any? ||
                          @user.errors[:country].any?)
            @message = @user.error_message 
            if @message
                LogService.new(signup_parameters, @message, 400).fatal
                render status: 400, json: {status: 400, error: @message}
            end
        else
            render status: 200, json: {status: 200, username: '', message: "Your info are valid"}
        end
    end

    ####################################################
    # 2. Telephone verification
    ####################################################
    api :POST, '/telephone_verification', 'telephone verification'
    param_group :user
    error :code => 400, :desc => "Telephone cannot be blank"
    error :code => 422, :desc => "Various validation messages"
    def telephone_verification
        @telephone = signup_parameters[:telephone].gsub(/[^0-9A-Za-z]/, '')
        if @telephone.present?
            check_telephone
            if !@message.present?
                send_telephone_verification_code
                @code_sent_at = Time.now
                render json: {status: 200, message: "Verification code sent", verification_code: @verification_code, code_sent_at: @code_sent_at}
            else
                LogService.new(signup_parameters, @message, 422).fatal
                render status: 422, json: {status: 400, error: @message}
            end
        else 
            @message = "Telephone cannot be blank"
            LogService.new(signup_parameters, @message, 422).fatal
            render status: 400, json: {status: 400, error: @message}
        end
    end

    ####################################################
    # 3. Create a user and create authtoken token
    ####################################################
    api :POST, '/signup', 'Create a User'
    param_group :user
    error :code => 400, :desc => "Various validation messages"
    returns :code => 200 do
        property :username, String, :desc => "Username"
        property :auth_token, String, :desc => "Token"
        property :message, String, :desc => "Sucess message"
    end
    def create
        if @api_key == ENV['MASTER_API_KEY']
            role = User.roles[:admin_]
            user = User.where(role: :admin_).last
            if user
                number = user.username.scan(/\d+/).last.to_i + 1
            else
                number = '0'
            end
            telephone = 18000000000 + number.to_i
            username = 'admin' + number.to_s
            password = generate_password
            params[:user][:password] = password
            params[:user][:password_confirmation] = password
            @user = User.new signup_parameters_admin
            @user.first_name = signup_parameters_admin[:first_name].downcase
            @user.last_name = signup_parameters_admin[:last_name].downcase
            @user.email = signup_parameters_admin[:email].downcase
            @user.username = username
            @user.telephone = telephone
            @user.country = 'usa'
            @user.role = role
            @user.phone_verified = true
            @user.registration_ip = request.remote_ip
            if @user.save
                send_registration_confirmation_email
                render status: 200, json: {status: 200, password: password, email: "#{@user.email}", message: "Admin account was succesfully created"}
            else
                @message = @user.error_message
                LogService.new(signup_parameters_admin, @message, 422).fatal
                render status: 400, json: {status: 400, error: @message}
            end
        elsif @api_key == ENV['USER_API_KEY'] 
            country = ISO3166::Country.find_country_by_name(signup_parameters[:country])
            if country
                params[:user][:country] = country.alpha3.downcase
            else
                if signup_parameters[:country].blank?
                    @message = "Invalid request"
                else
                    @message = "Invalid country name '#{signup_parameters[:country]}'"
                end 
                LogService.new(signup_parameters, @message, 400).fatal
                render status: 400, json: {status: 400, error: @message}
                return
            end 
            @user = User.new signup_parameters
            username = GenerateUsernameService.new("#{@user.first_name.downcase}.#{@user.last_name.downcase}")
            @user.first_name = signup_parameters[:first_name].downcase
            @user.last_name = signup_parameters[:last_name].downcase
            @user.email = signup_parameters[:email].downcase
            @user.telephone = signup_parameters[:telephone].gsub(/[^0-9A-Za-z]/, '')
            @user.username = username.set_username
            @user.phone_verified = true
            @user.registration_ip = request.remote_ip
            @user.date_of_birth = signup_parameters.has_key?(:date_of_birth) ? Date.parse(signup_parameters[:date_of_birth]) : nil
            ActiveRecord::Base.transaction do
                if @user.save
                    # @avatar = avatar_params[:avatar]
                    Account.create_user_account @user # Create acccount
                    Picture.create!(user_id: @user.id, avatar: nil) # Create profile picture
                    @auth_token = Authtoken.create_auth_token(@user.id,request.remote_ip, request.user_agent, params[:device_id])
                    if Rails.env != 'production'
                        # @user.email_verified = true
                        @user.account.profile.reload.balance = 1000
                        @user.account.profile.save!
                        @user.save!
                    end
                    send_registration_confirmation_email
                    render status: 200, json: {status: 200, username: "#{@user.username}", message: "Your account was succesfully created", auth_token: @auth_token.token}
                else
                    @message = @user.error_message
                    LogService.new(signup_parameters, @message, 422).fatal
                    render status: 400, json: {status: 400, error: @message}
                end
            end
        else
            @message = "Invalid request"
            LogService.new(signup_parameters_admin, @message, 422).fatal
            render status: 400, json: {status: 400, error: @message}    
        end
    end

    ## Method created to show the create admin documentation for Apipie. Not active method.
    # Signup for user and admin both go through the create method 
    api :POST, '/admin/signup', 'Create a admin'
    param_group :admin
    error :code => 400, :desc => "Various validation messages"
    returns :code => 200 do
        property :email, String, :desc => "Admin email"
        property :password, String, :desc => "Initial password"
        property :message, String, :desc => "Sucess message"
    end
    def create_admin
        render status: 200
    end

    ####################################################
    # Update username
    ####################################################
    api :PATCH, '/user/update_username', 'Update username'
    param_group :user
    def update_username
        complete_update_username
        log_info
        if !@status.present?
            render json: {message: @message, username: @user.username} 
        else
            render status: @status, json: {error: @message} 
        end
    end

    ####################################################
    # Invite Friends
    ####################################################
    api :POST, '/invite_friends', 'Invite friends'
    def invite_friends
        contact_list = invite_friends_parameter[:contacts] #params[:user][:contacts]
            # Will make this an async process in the future
            if (!(contact_list.nil? || contact_list.empty?))
            contact_list.each { |contact| 
                #Update the referral table
                if (!User.where(telephone: contact).exists?) &
                    ReferralContact.where(["user_id = ? and phone_number = ?", @user.id, contact]).empty? 
                    @referral = ReferralContact.create user_id: @user.id, phone_number: contact, reminder_count: 1
                    User.send_text_message contact, invite_friend_message
                end
            }
            render status: 202, json: {status: 202, Message: "Friends invites are on the way."} 
        else
            @message =  "Contact list empty"
            LogService.new(signup_parameters, @message, 400).fatal
            render status: 400, json: {status: 400, error: @message} 
        end
    end

    ####################################################
    # Update email
    ####################################################
    api :PATCH, '/update_email', 'Update email'
    param_group :user
    def update_email
        complete_update_email
        log_info
        if !@status.present?
            render status: 200, json: {status: 200, message: @message} 
        else
            render status: @status, json: {error: @message} 
        end
    end

    ####################################################
    # Confirm email
    ####################################################
    def confirm_email
        user = User.find_by_email_token(params[:token])
        if user
            if params.has_key?(:e)  # Email change verification
                @decrypted_email = EncryptDecryptService.new(params[:e]).decrypt
                if User.exists?(email: @decrypted_email)
                    LogService.new(params, 'Confirm email failed - email already esists', 422).fatal
                    redirect_to "#{ENV["APP_DOMAIN"]}/verifications/email-verification-failed.html"
                else
                    user.email = @decrypted_email
                    user.validate_email
                    user.save(validate: false)
                    if user.invalid? && user.errors[:email].any?
                        LogService.new(params, 'Confirm email failed - invalid email', 422).fatal
                        redirect_to "#{ENV["APP_DOMAIN"]}/verifications/email-verification-failed.html"
                    else
                        redirect_to "#{ENV["APP_DOMAIN"]}/verifications/email-verification-successful.html"
                    end
                end
            else  # Signup verification
                if user.role == 'admin_'
                    redirect_to "#{ENV["APP_DOMAIN"]}/verifications/password-update-form.html"
                else
                    user.validate_email
                    user.save(validate: false)
                    redirect_to "#{ENV["APP_DOMAIN"]}/verifications/email-verification-successful.html"
                end
            end
        else
            LogService.new(params, 'Confirm email failed - token not found', 422).fatal
            redirect_to "#{ENV["APP_DOMAIN"]}/verifications/email-verification-not-found.html"
        end
    end

    ####################################################
    # Change Password
    ####################################################
    def change_password # Not in use
        if @user
            if UserMailer.change_password_email(@user).deliver_now
                render status: 200, json: {status: 200, message: "We sent you an email to reset your password."}
            else
                LogService.new(params, 'We were not able to send the reset email. Try again later', 404).fatal
                render status: 404, json: {status: 404, error: "We were not able to send the reset email. Try again later"}
            end
        else
            render status: 404, json: {status: 404, error: "We don't recognize this account"}
        end
    end

    ####################################################
    # Redirect User to password update form
    ####################################################
    def password_update_form
        time_token = params[:token]
        encrypted_email = params[:e]
        decrypted_email = EncryptDecryptService.new(encrypted_email).decrypt
        if User.exists?(email: decrypted_email)
            @user = User.find_by(email: decrypted_email)
            redirect_to "#{ENV["APP_DOMAIN"]}/verifications/password-update-form.html?token=#{time_token}&e=#{EncryptDecryptService.new(@user.email).encrypt}"
        else
            LogService.new(params, 'User not found in password update form', 422).fatal
            redirect_to "#{ENV["APP_DOMAIN"]}/verifications/email-verification-failed.html"
        end
    end

    ####################################################
    # Update password of user from form
    ####################################################
    def update_password
        encrypted_email = params[:e]
        time_token = params[:token]
        puts "time_token: #{time_token}"
        pass = params[:password]
        decrypted_email = EncryptDecryptService.new(encrypted_email).decrypt
        link_expired = false
        if time_token.present?
            time = EncryptDecryptService.new(time_token).decrypt
            if Time.now > Time.at(time) + 15.minutes
                link_expired = true
            end
        end
        if link_expired == true
            render json: {url: "#{ENV["APP_DOMAIN"]}/verifications/password-update-expired.html"}
        else
            if User.exists?(email: decrypted_email)
                user = User.find_by(email: decrypted_email)
                user.update(password: pass, password_confirmation: pass)
                if user.role == 'admin_'
                    user.validate_email
                end
                render json: {url: "#{ENV["APP_DOMAIN"]}/verifications/password-update-success.html"}
            else
                LogService.new(params, 'Update password user not found', 422).fatal
                render json: {url: "#{ENV["APP_DOMAIN"]}/verifications/password-update-failed.html"}
            end
        end
    end

    ####################################################
    # Profile Update
    ####################################################
    def profile_update
        failure = ""
        success = ""
        complete_update_username
        log_info
        if @status.present?  
            failure = @message if @status == 422
        else
            success = "Profile updated successfully"
        end

        complete_update_email
        log_info
        if @status.present? && !failure.present?
            failure = @message if @status == 422
        else 
            success = "Profile update successfully and confirmation email sent to you"
        end 
 
        if failure.present?
            LogService.new(params, failure, 422).fatal
            render status:422, json: {error: failure}
        else
            render json: {message: success}
        end
    end

    protected
    def generate_password
        special_chars = ['@', '$', '%', '&', '!']
        SecureRandom.urlsafe_base64[0..10].gsub(/[^0-9A-Za-z]/, '').to_s + special_chars[rand(0..4)] + rand(0..9).to_s
    end

    def complete_update_email
        @message = ""
        @status = ""
        @email = signup_parameters[:email].strip

        if !@email.present?
            @message = "Email cannot be blank"
            @status = 422
        elsif @user.email == @email
            @message = "The email you entered is the same as your current email."
            @status = 400
        else # Valid input
            # @user.email = @email
            @user.set_email_token
            @user.save
            UserMailer.email_update_confirmation(@user, @email).deliver_now
            @message = "We've just sent you a confirmation email."
        end
    end

    def complete_update_username
        @message = ""
        @status = ""
        @username = signup_parameters[:username]
        
        if !@username.present?
            @message = "Username cannot be blank"
            @status = 422
        elsif @user.username == @username
            @message = "Username is the same as the current username."
            @status = 400 
        else # Valid input
            @username = @username.downcase.gsub(/[^0-9A-Za-z]/, '')
            @username = GenerateUsernameService.new(@username)
            @user.username = @username.set_username 
            if @user.save
                @message = "Username successfully updated"
            else
                @message = @user.error_message
                @status = 422
            end
        end
    end

    def check_telephone
        user = User.find_by_telephone(@telephone)
        phone_number = "+#{@telephone}"
        is_valid = Phoner::Phone.valid? phone_number
        if is_valid == false
            @message = "Telephone number is invalid"
        elsif user
            @message = "Telephone number is already associated with another account"
        elsif @user.present?
            if @user.telephone == @telephone
                @message = "Phone number is same as your current number"
            end
        end    
    end

    def log_info
        puts "----------- Response (Registration) --------------"
        logger.info @message
        puts "--------------------------------------------------" 
    end 

    def send_telephone_verification_code
        @verification_code = rand(100000...999999)
        SmsService.new({phone_number: @telephone, verification_code: @verification_code}, SmxTransaction.message_types[:phone_verification_])
        if @user.present?
            @user.update(pin: @verification_code, pin_sent_at: Time.now)
        end
    end

    def send_update_email_confirmation
        @user.set_email_token
        @user.save(validate: false) #This means save without validating user. This was required to persisted update to database. 
        UserMailer.email_update_confirmation(@user, @user.email).deliver_now
    end

    def send_registration_confirmation_email
        @user.set_email_token
        @user.save(validate: false) 
        UserMailer.registration_confirmation(@user).deliver_now
    end

    def verify_phone_message
        message = "Your Smx verification code is - #{@verification_code}"
    end 

    def invite_friend_message
        message =  "Hi, this is #{@user.first_name.capitalize}. I am using this new app called Smx " 
        message = message + "where you can pay or pool money with friends. "
        message = message + "Follow the link to download the app so we can send each other payments. "
        message = message + "https://smxmoney.com"
    end

    def signup_parameters
        params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :country, :device_id, :username, :telephone, :registration_state, :date_of_birth)
    end

    def signup_parameters_admin
        params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
    end

    def avatar_params
        params.require(:user).permit(:avatar)
    end

    def verification_code_parameter
        params.require(:user).permit(:code, :telephone, :code_sent_at)
    end

    def update_telephone_params
        params.require(:user).permit(:telephone)
    end

    def invite_friends_parameter
        params.require(:user).permit(:contacts => []) #({:contacts => []})  --> change to avoid unpermitted error
    end

    private
    # def validate_api_key
    #     api_key = request.headers['X-API-APIKEY']
    #     if api_key.blank? || api_key != ENV['USER_API_KEY']
    #         render status: 401, json: {status: 401, error: "API key not authentic", message: 'API key not authentic'}
    #     end
    # end

    ####################################################################
    # # # # # # #         Not currently used         # # # # # # # # # #  
    ####################################################################
    def validate_username
        @username = signup_parameters[:username]
        if !@username.present?
            @message = "Username cannot be blank"
            LogService.new(signup_parameters, @message, 422).fatal
            render status: 422, json: {error: @message}
            return
        end
        @username = @username.downcase.gsub(/\s+/, "")
        @user = User.find_by_username @username
        if @user
            @message = "Username #{@username} is already taken"
            LogService.new(signup_parameters, @message, 422).fatal
            username = GenerateUsernameService.new(@username).set_username
            render status: 200, json: {username: username, error: @message} 
        else
            @message = "Username is valid"
            LogService.new(signup_parameters, @message, 422).fatal
            username = GenerateUsernameService.new(@username).set_username
            render status: 200, json: {username: username, message: @message} 
        end 
    end

    api :PATCH, '/update_telephone', 'Update phone verified'
    param_group :user
    def update_telephone
        @telephone = update_telephone_params[:telephone].gsub(/[^0-9A-Za-z]/, '')
        check_telephone
        if @message.present?
            LogService.new(params, @message, 408).fatal
            render status: 408, json: {status: 408, error: @message}
        else
            @user.update(telephone: @telephone, phone_verified: true)
            render status: 200, json: {status: 200, message: "Your phone number has been verified!" }
        end
    end

    api :POST, '/verify_phone_number','Verify the phone number'
    def verify_phone_number
        render status: 403
        return 
        if @user # User check is redundant
            @telephone = signup_parameters[:telephone].gsub(/[^0-9A-Za-z]/, '')
            send_telephone_verification_code    
            render json: {status: 200, verification_code: @verification_code}
        else
            @message =  "User not found"
            LogService.new(params, @message, 404).fatal
            render status: 404, json: {status: 404, error: @message}
        end
    end

    api :POST, '/update_country','Update country' 
    param_group :user
    def update_country
        render status: 403
        return
        country = ISO3166::Country.find_country_by_name(signup_parameters).alpha3
        if @user.update_attribute("country",country)
            render json: {status: 200,message: "successfully updated country"}
        else
            @message = @user.errors.full_messages
            LogService.new(params, @message, 400).fatal
            render json: {status: 400,message: @message}
        end
    end
  
    api :PATCH, '/user/update_picture','Update profile pic'
    param_group :user
    def update_picture
        if @user.update_attribute("avatar",avatar_params)
            render json: { status: 200, message: "avatar successfully updated" }
        else
            @message = @user.errors.full_messages 
            LogService.new(params, @message, 400).fatal
            render json: { status: 400, message: @message}
        end
    end

    api :PATCH, '/user/update_avatar','Update profile pic'
    param_group :user
    def update_avatar 
        render status: 403
        return
        @picture  = @user.pictures.where(id: params[:id])
        if  @picture.present?
            @picture.update_attribute("avatar",avatar_params[:avatar])
            render json: { status: 200, message: "avatar successfully updated" }
        else 
            @picture = Picture.new(user_id: @user.id,avatar: avatar_params[:avatar])
            @picture.save
            render json: { status: 200, message: "avatar successfully created" }
        end
    end
    # # # # # # # Not currently used # # # # # # # # # #
end

