class Api::V1::FeesAndCommissionsController < Api::V1::BaseController
  before_action :set_fees_and_commission, only: [:show, :update, :destroy]
  
  def_param_group :fees_and_commission do
    param :fees_and_commission, Hash, required: true, action_aware: true do
      param :amount_from, /\A(\d+[\.,]?\d*|\d*[\.,]?\d+)\Z/, required: true, allow_nil: false
      param :amount_to, /\A(\d+[\.,]?\d*|\d*[\.,]?\d+)\Z/, required: true, allow_nil: false
      param :amount, /\A(\d+[\.,]?\d*|\d*[\.,]?\d+)\Z/, required: true, allow_nil: false
      param :percentage, /\A(\d+[\.,]?\d*|\d*[\.,]?\d+)\Z/, required: true, allow_nil: false
      param :percent_base, [true, false], required: true, allow_nil: false
      param :active, [true, false], required: true, allow_nil: false
      param :fc_type, Integer, required: true, allow_nil: false
      param :rank, Integer, required: true, allow_nil: false
      param :money_type, Integer, required: true, allow_nil: false
      param :tansaction_type, Integer, required: true, allow_nil: false
      param :sending_country_id, Integer, required: true, allow_nil: false
      param :receiving_country_id, Integer, required: true, allow_nil: false
    end
  end

  #api :GET, '/fees_and_commissions', 'List fees_and_commissions'
  def index
    @fees_and_commissions = FeesAndCommission.page(params[:page]).per(params[:per])

    render json: @fees_and_commissions
  end

  #api :GET, '/fees_and_commissions/:id', 'Show fees_and_commission'
  def show
    render json: @fees_and_commission
  end

  #api :POST, '/fees_and_commissions', 'Create fees_and_commission'
  param_group :fees_and_commission
  def create
    @fees_and_commission = FeesAndCommission.new(fees_and_commission_params)

    if @fees_and_commission.save
      render json: @fees_and_commission, status: :created, location: @fees_and_commission
    else
      render json: @fees_and_commission.errors, status: :unprocessable_entity
    end
  end

  #api :PUT, '/fees_and_commissions/:id', 'Update fees_and_commission'
  param_group :fees_and_commission
  def update
    if @fees_and_commission.update(fees_and_commission_params)
      render json: @fees_and_commission
    else
      render json: @fees_and_commission.errors, status: :unprocessable_entity
    end
  end

  #api :DELETE, '/fees_and_commissions/:id', 'Destroy fees_and_commission'
  def destroy
    @fees_and_commission.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_fees_and_commission
      @fees_and_commission = FeesAndCommission.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def fees_and_commission_params
      params.require(:fees_and_commission).permit(:amount_from, :amount_to, :amount, :percentage, :percent_based, :active, :fc_type, :rank, :money_type, :tansaction_type, :sending_country_id, :receiving_country_id)
    end
end
