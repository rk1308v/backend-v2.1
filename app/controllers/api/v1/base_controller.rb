require "#{Rails.root}/lib/errors/errors.rb"

class Api::V1::BaseController < ActionController::API
    rescue_from Errors::Errors, with: :render_error
    before_action :validate_api_key
    before_action :set_default_response_format,:authenticate_user_from_token!

    rescue_from(ActionController::ParameterMissing) do |parameter_missing_exception|
        render status: 404, json: {status: 404, error: 'Required parameters are missing'}
    end

    private

    def validate_api_key
        @api_key = request.headers['X-API-APIKEY']
        if @api_key.blank?
            render status: 401, json: {status: 401, error: "API key not authentic", message: 'API key not authentic'}
        elsif @api_key == ENV['USER_API_KEY']
            return
        elsif @api_key == ENV['ADMIN_API_KEY']
            return
        elsif @api_key == ENV['MASTER_API_KEY'] && request.headers['HTTP_X_ROLE'].to_i == User.roles[:admin_]
            return
        else
            render status: 401, json: {status: 401, error: "API key not authentic", message: 'API key not authentic'}
        end
    end

    def render_error(error)
        render(json: error, status: error.status)
    end

    def set_default_response_format
        request.format = :json
    end

    def authenticate_user_from_token!
        logger.info params.as_json({except: :auth_token})

        user_token = params[:auth_token].presence
        auth_token =  Authtoken.find_by_token(user_token.to_s)
        @user = auth_token.user if auth_token.present?

        if @user && auth_token.is_valid?
            auth_token.update(last_used_at: DateTime.now)
            fcm_token = request.headers['HTTP_X_API_FCMTOKEN']
            apns_token = request.headers['HTTP_X_API_APNS']
            is_push_enabled = request.headers['HTTP_X_API_PUSHENABLED']
            if fcm_token.present?
                @user.update(fcm_token: fcm_token, apns_token: apns_token, push_enabled: is_push_enabled.to_i == 1 ? true : false)
            end
        else
            if !@user
                warden.custom_failure!
                render status: 401, json: {status: 401, error: "Authtoken error / User not found"}
            else
                render status: 401, json: {status: 401, error: "Session expired", message: 'Session Expired'}
            end
        end
    end
end
