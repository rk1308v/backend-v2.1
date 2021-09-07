class Api::V1::SusuTransactionsController < Api::V1::BaseController
  before_action :set_susu_transaction, only: [:show, :update, :destroy]
  
  def_param_group :susu_transaction do
    param :susu_transaction, Hash, required: true, action_aware: true do
      param :net_amount, /\A(\d+[\.,]?\d*|\d*[\.,]?\d+)\Z/, required: true, allow_nil: false
      param :fees, /\A(\d+[\.,]?\d*|\d*[\.,]?\d+)\Z/, required: true, allow_nil: false
      param :round, Integer, required: true, allow_nil: false
      param :trans_type, Integer, required: true, allow_nil: false
      param :payment_type, Integer, required: true, allow_nil: false
      param :status, Integer, required: true, allow_nil: false
      param :description, String, required: true, allow_nil: false
      param :susu_id, Integer, required: true, allow_nil: false
      param :user_id, Integer, required: true, allow_nil: false
    end
  end

  #api :GET, '/susu_transactions', 'List Susu Transactions'
  def index
    @susu_transactions = SusuTransaction.page(params[:page]).per(params[:per])

    render json: @susu_transactions
  end

  #api :GET, '/susu_transactions/:id', 'Show Susu Transaction'
  def show
    render json: @susu_transaction
  end

  #api :POST, '/susu_transactions', 'Create Susu Transaction'
  param_group :susu_transaction
  def create
    @susu_transaction = SusuTransaction.new(susu_transaction_params)

    if @susu_transaction.save
      render json: @susu_transaction, status: :created, location: @susu_transaction
    else
      render json: @susu_transaction.errors, status: :unprocessable_entity
    end
  end

  #api :PUT, '/susu_transactions/:id', 'Update Susu Transaction'
  param_group :susu_transaction
  def update
    if @susu_transaction.update(susu_transaction_params)
      render json: @susu_transaction
    else
      render json: @susu_transaction.errors, status: :unprocessable_entity
    end
  end

  #api :DELETE, '/susu_transactions/:id', 'Destroy Susu Transaction'
  def destroy
    @susu_transaction.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_susu_transaction
      @susu_transaction = SusuTransaction.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def susu_transaction_params
      params.require(:susu_transaction).permit(:net_amount, :round, :status, :fees, :trans_type, :payment_type, :susu_id, :user_id)
    end
end
