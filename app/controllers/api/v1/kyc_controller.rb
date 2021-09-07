class Api::V1::KycController < Api::V1::BaseController
    
    api :POST, '/upload_document', 'Upload document'
    
    def upload_document
        if params.has_key?(:user)
            if @user.present?
                @user.update(kyc: params[:user][:kyc_document], kyc_verified: true)
                puts @user.errors.full_messages
                puts "Errors: #{@user.errors.inspect}"
                render status: 200, json: {status: 200, message: "KYC Document upload received"}
            else
                render status: 404, json: {status: 404, error: "You are not authorized to upload document"}
            end
        else
            render status: 401, json: {status: 401, error: "Required parameters are missing"}
        end
        
    end

    private
    def kyc_base64_params
      	params.require(:user).permit(:kyc_document => [:data , :filename])
    end
end