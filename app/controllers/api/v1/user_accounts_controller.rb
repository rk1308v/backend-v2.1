class Api::V1::UserAccountsController < Api::V1::BaseController
  before_action :set_user_account, only: [:show, :update, :destroy]

  def_param_group :user_account do
    param :user_account, Hash, required: true, action_aware: true do
      param :balance, /\A(\d+[\.,]?\d*|\d*[\.,]?\d+)\Z/, required: true, allow_nil: false
      param :send_limit, /\A(\d+[\.,]?\d*|\d*[\.,]?\d+)\Z/, required: true, allow_nil: false
      param :monthtly_send_limit, /\A(\d+[\.,]?\d*|\d*[\.,]?\d+)\Z/, required: true, allow_nil: false
      param :description, String, required: true, allow_nil: false
      #param :currency_id, Integer, required: true, allow_nil: false
    end
  end

  #api :GET, '/user_accounts','List User Accounts'
  def index
    @user_accounts = @user.user_accounts.page(params[:page]).per(params[:per])

    render json: @user_accounts
  end

  #api :GET, '/user_accounts/:id','Show User Account'
  def show
    render json: @user_account
  end

  #api :POST, '/user_accounts','Create User Account'
  param_group :user_account
  def create
    @user_account = @user.user_accounts.new(user_account_params)
    if @user_account.save
      render json: @user_account, status: :created
    else
      render json: @user_account.errors, status: :unprocessable_entity
    end
  end

  #api :PUT, '/user_accounts/:id','Update User Account'
  param_group :user_account
  def update
    if @user_account.update(user_account_params)
      render json: @user_account
    else
      render json: @user_account.errors, status: :unprocessable_entity
    end
  end

  #api :DELETE, '/user_accounts/:id','Destroy User Account'
  def destroy
    @user_account.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_account
      @user_account = @user.user_accounts.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def user_account_params
       params.require(:user_account).permit(:balance, :send_limit, :monthtly_send_limit, :description)
    end
end
