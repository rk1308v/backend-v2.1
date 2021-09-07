class Api::V1::UserTransactionsController < Api::V1::BaseController
    before_action :set_user_transaction, only: [:show, :update, :destroy]
    skip_before_action :authenticate_user_from_token!, :validate_api_key, :only => [:post_segovia_params]
    
    def_param_group :user_transaction_ do
        param :user_transaction_, Hash, required: true, action_aware: true do
            param :net_amount, /\A(\d+[\.,]?\d*|\d*[\.,]?\d+)\Z/, required: true, allow_nil: false
            param :fees, /\A(\d+[\.,]?\d*|\d*[\.,]?\d+)\Z/, required: true, allow_nil: false
            param :exchange_rate, /\A(\d+[\.,]?\d*|\d*[\.,]?\d+)\Z/, required: true, allow_nil: false
            param :country_from, String, required: true, allow_nil: false
            param :country_to, String, required: true, allow_nil: false
            param :trans_type, Integer, required: true, allow_nil: false
            param :payment_type, Integer, required: true, allow_nil: false
            param :status, Integer, required: true, allow_nil: false
            param :description, String, required: true, allow_nil: false
            param :sender_id, Integer, required: true, allow_nil: false
            param :recipient_id, Integer, required: true, allow_nil: false
        end
    end

    def_param_group :user_transaction do
        param :user_transaction, Hash, required: true, action_aware: true do
            param :amount, /\A(\d+[\.,]?\d*|\d*[\.,]?\d+)\Z/, required: true, allow_nil: false
            param :recipient_id, Integer, required: true, allow_nil: false
        end
    end

    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    #    Send Money
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    api :POST, '/send_money','Send money to a user'
    param_group :user_transaction
    def send_money
        @amount = user_transaction_params[:amount].to_s
        #recipient_ids = user_transaction_params[:recipient_ids]
        # trans_type = SmxTransaction.trans_types[:send_]
        puts "user_transaction_params: #{user_transaction_params}"
        @recipient_id = user_transaction_params[:recipient_id]
        @country_code = user_transaction_params[:country_code] # Not used now
        @recipient_telephone = user_transaction_params[:recipient_telephone]
        @notification_id = user_transaction_params[:notification_id]

        if user_transaction_params[:is_confirmed].to_i == 1 # TODO Need to revisit this. Should use request Id. What is is_confirmed used for?
            if @notification_id # TODO Need to revisit this. Should use request Id  
                user_transaction_params[:description] = "#{@user.first_name.capitalize} #{@user.last_name.capitalize} paid your request."
            else 
                user_transaction_params[:description] = "#{@user.first_name.capitalize} #{@user.last_name.capitalize} sent you money."   
            end
        end

        message = validate_params("send")
        if message
            render status: 412, json: {status: 412, error: message}
            return
        end

        @transaction = SendMoneyService.new(@user, user_transaction_params)
        resp_data = @transaction.send_money
        if resp_data.nil?
            render status: 500, json: {status: 500, error: "Oops! Something went wrong. Try again later"}
        else
            if @notification_id and user_transaction_params[:is_confirmed].to_i == 1
                read_update_notification
            end
            render json: resp_data
        end
        
    end

    def validate_telephone telephone
        ph_no = "+#{telephone.gsub('+', '')}"
        if !Phoner::Phone.valid? ph_no
            'Phone number invalid. Please verify number and try again'
        end
    end

    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    #    request Money
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    api :POST, '/request_money','Request money from a user'
    param_group :user_transaction
    def request_money
        @amount = user_transaction_params[:amount]
        #recipient_ids = user_transaction_params[:recipient_ids]
        @recipient_id = user_transaction_params[:recipient_id]
        trans_type = SmxTransaction.trans_types[:request_]
        description = user_transaction_params[:description]
        message = validate_params("request")
        if message
            render status: 412, json: {status: 412, error: message}
        else
            @recipient = User.find_by_id @recipient_id
            @transaction = UserTransactionService.new(@user, @recipient, @amount, trans_type, description, '', '', '')
            resp_data = @transaction.request_money
            render status: 200, json: resp_data.try(:first)  
        end
    end

    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    #    Forbidden APIs
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    #api :GET, '/user_transactions', 'List User Transactions'
    def index
        render status: 403
        return
        @user_transactions = UserTransaction.page(params[:page]).per(params[:per])
        render json: @user_transactions
    end

    #api :GET, '/user_transactions/:id', 'Show User Transaction'
    def show
        if @user_transaction.sender_id == @user.id || @user_transaction.recipient_id == @user.id
            transaction_data = @user_transaction.as_json(except: [:recipient_id, :transaction_id, :transaction_service, :job_id, :response_hash])
            transaction_data[:recipient_name] = @user_transaction.recipient.present? ? @user_transaction.recipient.full_name : @user_transaction.recipient_telephone
            transaction_data[:description] = @user_transaction.description.blank? ? '' : @user_transaction.description
            render status: 200, json: {status: 200, summary: @user_transaction.summary(@user)}
        else
            render status: 404, json: {status: 404, message: 'You are not authorized to perform this action'}
        end
    end

    #api :POST, '/user_transactions', 'Create User Transaction'
    #param_group :user_transaction
    def create
        render status: 403
        return
        @user_transaction = UserTransaction.new(user_transaction_params)
        if @user_transaction.save
            render json: @user_transaction, status: :created, location: @user_transaction
        else
            render json: @user_transaction.errors, status: :unprocessable_entity
        end
    end

    #api :PUT, '/user_transactions/:id', 'Update User Transaction'
    #param_group :user_transaction
    def update
        render status: 403
        return
        if @user_transaction.update(user_transaction_params)
            render json: @user_transaction
        else
            render json: @user_transaction.errors, status: :unprocessable_entity
        end
    end

    #api :DELETE, '/user_transactions/:id', 'Destroy User Transaction'
    def destroy
        render status: 403
        return
        @user_transaction.destroy
    end

    def post_segovia_params
        Rails.logger.info(params)
        SegoviaResponseWorker.set(queue: 'segovia_response_queue').perform_in(10.seconds, params)
    end

    private
    def read_update_notification
        notification = @user.notifications.find_by_id(@notification_id)
        if notification
            notification[:read] = true
            notification.save
        end
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_user_transaction
        @user_transaction = UserTransaction.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def user_transaction_params
        params.require(:user).permit(
            :amount,
            :recipient_id, 
            :description, 
            :recipient_telephone, 
            :is_confirmed, 
            :country_code, 
            :payment_method, 
            :source_token, 
            :card_type, 
            :payment_method_number, 
            :recipient_name, 
            :first_name, 
            :last_name, 
            :notification_id)
    end

    # Validate Params
    def validate_params type
        # We need to check amount should not contain , in it. If it contains 
        # , then need to show message to user. 
        if !@amount.present?
            "Amount cannot be null."
        elsif @amount.to_f <= 0.0
            "You cannot #{type} 0.00 amount."
        elsif !@recipient_id.present? && !@recipient_telephone.present?
            "Recipient ID cannot be null."
        end
        if @recipient_telephone.present?
            ph_no = "+#{@recipient_telephone.gsub('+', '')}"
            if !Phoner::Phone.valid? ph_no
                'Phone number invalid. Please verify number and try again'
            end
        end
    end

end
