class Api::V1::AccountsController < Api::V1::BaseController
    before_action :set_account, only: [:show, :update, :destroy]
  
    def_param_group :account do
        param :account, Hash, required: true, action_aware: true do
            param :user_id, Integer, required: true, allow_nil: false
            param :profile_id, Integer, required: true, allow_nil: false
            param :profile_type, Integer, required: true, allow_nil: false
        end
    end

    #api :GET, '/accounts', 'List Accounts'
    def index
        render status: 403
        return
        @accounts = Account.page(params[:page]).per(params[:per])
        render json: @accounts
    end

    #api :GET, '/accounts/:id', 'Show Account'
    def show
        render status: 403
        return
        render json: @account
    end

    #api :POST, '/accounts', 'Create Account'
    #param_group :account
    def create
        render status: 403
        return
        @account = Account.new(account_params)
        if @account.save
            render json: @account, status: :created, location: @account
        else
            render json: @account.errors, status: :unprocessable_entity
        end
    end

    #api :PUT, '/accounts/:id', 'Update Account'
    #param_group :account
    def update
        render status: 403
        return
        if @account.update(account_params)
            render json: @account
        else
            render json: @account.errors, status: :unprocessable_entity
        end
    end

    #api :DELETE, '/accounts/:id', 'Destroy Account'
    def destroy
        render status: 403
        return
        @account.destroy
    end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_account
        @account = Account.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def account_params
        params.require(:account).permit(:user_id, :profile_id, :profile_type)
    end
end
