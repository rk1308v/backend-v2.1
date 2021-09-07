class Api::V1::SmxTransactionsController < Api::V1::BaseController
  before_action :set_smx_transaction, only: [:show, :update, :destroy]

  def_param_group :smx_transaction do
    param :smx_transaction, Hash, required: true, action_aware: true do
      param :amount, /\A(\d+[\.,]?\d*|\d*[\.,]?\d+)\Z/, required: true, allow_nil: false
      param :transactionable_id, Integer, required: true, allow_nil: false
      param :transactionable_type, Integer, required: true, allow_nil: false
    end
  end

  # GET /smx_transactions
  def index
    @smx_transactions = SmxTransaction.all

    render json: @smx_transactions
  end

  # GET /smx_transactions/1
  def show
    render json: @smx_transaction
  end

  # POST /smx_transactions
  def create
    @smx_transaction = SmxTransaction.new(smx_transaction_params)

    if @smx_transaction.save
      render json: @smx_transaction, status: :created, location: @smx_transaction
    else
      render json: @smx_transaction.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /smx_transactions/1
  def update
    if @smx_transaction.update(smx_transaction_params)
      render json: @smx_transaction
    else
      render json: @smx_transaction.errors, status: :unprocessable_entity
    end
  end

  # DELETE /smx_transactions/1
  def destroy
    @smx_transaction.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_smx_transaction
      @smx_transaction = SmxTransaction.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def smx_transaction_params
      params.require(:smx_transaction).permit(:amount, :transactionable_id, :transactionable_type)
    end
end
