class Api::V1::AgentTransactionsController < Api::V1::BaseController
    before_action :set_agent_transaction, only: [:show, :update, :destroy]
  
    def_param_group :agent_transaction do
        param :agent_transaction, Hash, required: true, action_aware: true do
            param :net_amount, /\A(\d+[\.,]?\d*|\d*[\.,]?\d+)\Z/, required: true, allow_nil: false
            param :fees, /\A(\d+[\.,]?\d*|\d*[\.,]?\d+)\Z/, required: true, allow_nil: false
            param :commission, /\A(\d+[\.,]?\d*|\d*[\.,]?\d+)\Z/, required: true, allow_nil: false
            param :trans_type, Integer, required: true, allow_nil: false
            param :payment_type, Integer, required: true, allow_nil: false
            param :status, Integer, required: true, allow_nil: false
            param :description, String, required: true, allow_nil: false
            param :user_id, Integer, required: true, allow_nil: false
            param :agent_id, Integer, required: true, allow_nil: false
        end
    end

    #api :GET, '/agent_transactions', 'List Agent Transactions'
    def index
        @agent_transactions = AgentTransaction.page(params[:page]).per(params[:per])
        render json: @agent_transactions
    end

    #api :GET, '/agent_transactions/:id', 'Show Agent Transaction'
    def show
        render json: @agent_transaction
    end

    #api :POST, '/agent_transactions', 'Create Agent Transaction'
    #param_group :agent_transaction
    def create
        @agent_transaction = AgentTransaction.new(agent_transaction_params)
        if @agent_transaction.save
            render json: @agent_transaction, status: :created, location: @agent_transaction
        else
            render json: @agent_transaction.errors, status: :unprocessable_entity
        end
    end

    #api :PUT, '/agent_transactions/:id', 'Update Agent Transaction'
    #param_group :agent_transaction
    def update
        if @agent_transaction.update(agent_transaction_params)
            render json: @agent_transaction
        else
            render json: @agent_transaction.errors, status: :unprocessable_entity
        end
    end

    #api :DELETE, '/agent_transactions/:id', 'Destroy Agent Transaction'
    def destroy
        @agent_transaction.destroy
    end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_agent_transaction
        @agent_transaction = AgentTransaction.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def agent_transaction_params
        params.require(:agent_transaction).permit(:net_amount, :trans_type, :payment_type, :status, :fees, :commission, :agent, :user_id)
    end
end
