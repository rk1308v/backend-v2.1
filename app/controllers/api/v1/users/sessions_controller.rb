class Api::V1::Users::SessionsController < Api::V1::BaseController
    # before_action :validate_api_key

    def_param_group :user do
        param :user, Hash, required: true, action_aware: true do
            param :login, String, required: true
            param :password, String, required: true
        end
    end

    def_param_group :logout do
        param :auth_token, String, required: true
    end

    skip_before_action :authenticate_user_from_token!, :only => [:create, :destroy, :reset_password, :validate_password_code, :update_password_with_code]

    # It logs in a user by creating a new authtoken
    # It creates a user and calls the Authtoken method
    api :POST, '/login','Login a User'
    param_group :user
    def create
        # Check if user exists
        @user = User.find_for_database_authentication(signin_parameters)
        if @user.present?
            if @user.role == 'admin_' && @api_key != ENV['ADMIN_API_KEY']
                render status: 400, json: {status: 400, error: "Invalid request"}
                return
            end
        else
            return invalid_login_attempt
        end
        # Check if password valid
        if @user.valid_password?(signin_parameters[:password])
            sign_in(@user)
            if signin_parameters.has_key?(:device_id)
                device_id = signin_parameters[:device_id]
                if device_id.present?
                    if @user.device_id.blank?
                        @user.update(device_id: device_id)
                    else
                        if @user.device_id != device_id
                            UserMailer.device_change(@user, request.remote_ip).deliver_now
                        end
                    end
                end
            end
            @auth_token = Authtoken.create_auth_token(@user.id,request.remote_ip, request.user_agent, signin_parameters[:device_id])
            render status: 200, json: {status: 200, message: "user succesfully logged in",auth_token:@auth_token.token}
        else
            @user.failed_attempts += 1
            @user.save!
            invalid_login_attempt
        end
    end

    api :DELETE, '/logout','Logout a User'
    param_group :logout
    #It destroyes the user authtoken hence logging out the user
    def destroy
        user_token = params[:auth_token].presence
        auth_token =  Authtoken.find_by_token(user_token.to_s)
        user  = auth_token.user if auth_token.present?
        if user
            user.update(fcm_token: '', apns_token: '', push_enabled: false)
            sign_out(user)
            Authtoken.destroy_auth_token(user_token.to_s)
            render status: 200, json: {status: 200, message: "user succesfully logged out."}
        else
            user_not_found
        end
    end
  
    api :POST, '/reset_password','Reset Password' # Not used any more
    param_group :user
    def reset_password
        puts "reset_password_parameter: #{reset_password_parameter}"
        @user = User.find_by_email reset_password_parameter[:email].downcase
        if @user
            @password_reset_code = rand(100000...999999)
            if UserMailer.reset_password_email(@user, @password_reset_code).deliver_now
                @user.update( reset_password_token: @password_reset_code, 
                                 reset_password_sent_at: Time.now)
                render status: 200, json: {status: 200, message: "We sent you an email to reset your password."}
            else
                render status: 404, json: {status: 404, error: "We were not able to send the reset email. Try again later"}
            end
        else 
            render status: 404, json: {status: 404, error: "We don't recognize this email."}
        end    
    end 

    api :PATCH, '/update_password','Update Password'
    param_group :user
    def update_password
        if !@user.valid_password? params[:user][:old_password]
            render status: 404, json: {status: 404, error: "Old password is wrong"}
        elsif @user.update password_parameters
            render json: {status: 200, message: "Your password has been succesfully updated!"}
        else  
            render status: 404, json: {status: 404, error: @user.errors.full_messages}
        end
    end

    api :POST, '/validate_password_code','validate password code'
    param_group :user
    def validate_password_code
        if !password_code_parameters[:code].present?
            render status: 400, json: {status: 400, error: "Code cannot be empty."}
            return
        end

        @user = User.find_by_email password_code_parameters[:email].downcase
        if @user
            if @user.reset_password_token.nil?
                render status: 400, json: {status: 400, error: "The code you entered is invalid" }
            elsif Time.now > @user.reset_password_sent_at.advance(minutes: 30)
                render status: 422, json: {status: 422, error: "Your code has expired. Please request another one."}
            elsif (password_code_parameters[:code] == @user.reset_password_token)
                render json: {status: 200, message: "Your reset code has been succesfully validated!" }
            else
                render status: 422, json: {status: 422, error: "The code is invalid"}
            end
        else
            render status: 404, json: {status: 404, error: "We dont recognize this email."}
        end
    end

    api :POST, '/update_password_with_code','Update Password with code'
    param_group :user
    def update_password_with_code 
        if !password_code_parameters[:code].present?
            render status: 400, json: {status: 400, error: "Code cannot be empty."}
            return
        end
        @user = User.find_by_email password_code_parameters[:email]
        if @user
            if @user.reset_password_token.nil?
                render status: 417, json: {status: 417, error: "The code you entered is invalid" }
            elsif Time.now > @user.reset_password_sent_at.advance(minutes: 35)
                render status: 408, json: {status: 408, error: "Your time has expired. Please start from the beginning."}
            elsif password_code_parameters[:code] == @user.reset_password_token
                if password_parameters.has_key?(:password) && password_parameters.has_key?(:password_confirmation)
                    if @user.update password_parameters
                        @user.update_attribute(:reset_password_token, nil)
                        render json: {status: 200, message: "Your password has been succesfully updated!" }
                    else
                        render status: 400, json: {status: 400, error: @user.errors.full_messages.last}
                    end
                else
                    render status: 422, json: {status: 422, error: "Password or password confirmation is empty" }  
                end
            else
                render status: 422, json: {status: 422, error: "The code you entered is invalid" }  
            end   
        else
            render status: 404, json: {status: 404, error: "We dont recognize this email."}
        end
    end

    private
    def password_code_parameters
        params.require(:user).permit(:email, :code)
    end

    def password_parameters
        params.require(:user).permit(:password, :password_confirmation)
    end

    def reset_password_parameter
        params.require(:user).permit(:email)
    end

    def signin_parameters
        params.require(:user).permit( :login,:email, :password, :device_id)
    end

    def invalid_login_attempt
        warden.custom_failure!
        #render status: 400, json: {error: "Error with your email or password"}
        render status: 400, json: {status: 400, error: "The username or password you entered is incorrect."}
    end

    def user_not_found
        render status: 404, json: {status: 404, error: "User not found"}
    end

    # def validate_api_key
    #     api_key = request.headers['X-API-APIKEY']
    #     if api_key.blank? || api_key != ENV['USER_API_KEY']
    #         render status: 401, json: {status: 401, error: "KOku API key not authentic", message: 'Koku API key not authentic'}
    #     end
    # end
end
