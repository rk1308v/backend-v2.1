class Api::V1::AdminTransactionsController < Api::V1::BaseController
    before_action :set_admin_transaction, only: [:show, :update, :destroy]
  
    def_param_group :admin_transaction do
        param :admin_transaction, Hash, required: true, action_aware: true do
            param :amount, /\A(\d+[\.,]?\d*|\d*[\.,]?\d+)\Z/, required: true, allow_nil: false
            param :trans_type, Integer, required: true, allow_nil: false
            param :status, Integer, required: true, allow_nil: false
            param :description, String, required: true, allow_nil: false
            param :recipient_id, Integer, required: true, allow_nil: false
            param :admin_id, Integer, required: true, allow_nil: false
        end
    end

    #api :GET, '/admin_transactions', 'List Transactions'
    def index
        @admin_transactions = AdminTransaction.page(params[:page]).per(params[:per])
        render json: @admin_transactions
    end

    #api :GET, '/admin_transactions/:id', 'Show Transaction'
    def show
        render json: @admin_transaction
    end

    #api :POST, '/admin_transactions', 'Create Transaction'
    #param_group :admin_transaction
    def create
        @admin_transaction = AdminTransaction.new(admin_transaction_params)
        if @admin_transaction.save
            render json: @admin_transaction, status: :created, location: @admin_transaction
        else
            render json: @admin_transaction.errors, status: :unprocessable_entity
        end
    end

    #api :PUT, '/admin_transactions/:id', 'Update Transaction'
    #param_group :admin_transaction
    def update
        if @admin_transaction.update(admin_transaction_params)
            render json: @admin_transaction
        else
            render json: @admin_transaction.errors, status: :unprocessable_entity
        end
    end

    #api :DELETE, '/admin_transactions/:id', 'Destroy Transaction'
    def destroy
        @admin_transaction.destroy
    end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_transaction
        @admin_transaction = AdminTransaction.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def admin_transaction_params
        params.require(:admin_transaction).permit(:amount, :trans_type, :status, :admin_id, :recipient_id)
    end
end
