class Api::V1::PaymentProcessorsController < Api::V1::BaseController
  before_action :set_payment_processor, only: [:show, :update, :destroy]
  
  def_param_group :payment_processor do
    param :payment_processor, Hash, required: true, action_aware: true do
      param :name, String, required: true, allow_nil: false
      param :username, String, required: true, allow_nil: false
      param :password, String, required: true, allow_nil: false
      param :country_id, Integer, required: true, allow_nil: false
    end
  end

  #api :GET, '/payment_processors', 'List Payment Processors'
  def index
    @payment_processors = PaymentProcessor.page(params[:page]).per(params[:per])

    render json: @payment_processors
  end

  #api :GET, '/payment_processors/:id', 'Show Payment Processor'
  def show
    render json: @payment_processor
  end

  #api :POST, '/payment_processors', 'Create Payment Processor'
  param_group :payment_processor
  def create
    @payment_processor = PaymentProcessor.new(payment_processor_params)

    if @payment_processor.save
      render json: @payment_processor, status: :created, location: @payment_processor
    else
      render json: @payment_processor.errors, status: :unprocessable_entity
    end
  end

  #api :PUT, '/payment_processors/:id', 'Update Payment Processor'
  param_group :payment_processor
  def update
    if @payment_processor.update(payment_processor_params)
      render json: @payment_processor
    else
      render json: @payment_processor.errors, status: :unprocessable_entity
    end
  end

  #api :DELETE, '/payment_processors/:id', 'Destroy Payment Processor'
  def destroy
    @payment_processor.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_payment_processor
      @payment_processor = PaymentProcessor.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def payment_processor_params
      params.require(:payment_processor).permit(:name, :username, :password, :country_id)
    end
end
