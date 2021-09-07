class Api::V1::PaymentMethodsController < Api::V1::BaseController
    before_action :set_payment_method, only: [:show, :update, :destroy]

    def_param_group :payment_method do
        param :payment_method, Hash, required: true, action_aware: true do
            param :issuer_name, String, required: true, allow_nil: false
            param :valid, [true, false], required: true, allow_nil: false
            param :token, String, required: true, allow_nil: false
            param :token_valid_until, DateTime, required: true, allow_nil: false
            param :payment_type, Integer, required: true, allow_nil: false
            param :card_type, Integer, required: true, allow_nil: false
            param :description, String, required: true, allow_nil: false
            param :country_id, String, required: true, allow_nil: false
        end
    end

    #api :GET, '/payment_methods', 'List Payment Methods'
    def index
        @payment_methods = @user.payment_methods.page(params[:page]).per(params[:per])
        render json: @payment_methods
    end

    #api :GET, '/payment_methods/:id', 'Show Payment Method'
    def show
        render json: @payment_method
    end

    #api :POST, '/payment_methods', 'Create Payment Method'
    param_group :payment_method
    def create
        @payment_method = @user.payment_methods.new(payment_method_params)
        if @payment_method.save
            render json: @payment_method, status: :created, location: @payment_method
        else
            render json: @payment_method.errors, status: :unprocessable_entity
        end
    end

    #api :PUT, '/payment_methods/:id', 'Update Payment Method'
    param_group :payment_method
    def update
        if @payment_method.update(payment_method_params)
            render json: @payment_method
        else
            render json: @payment_method.errors, status: :unprocessable_entity
        end
    end

    #api :DELETE, '/payment_methods/:id', 'Destroy Payment Method'
    def destroy
        @payment_method.destroy
    end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_payment_method
        @payment_method = @user.payment_method.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def payment_method_params
        params.require(:payment_method).permit(:issuer_name, :valid, :token, :token_valid_until, :payment_type, :card_type, :description, :country_id)
    end
end
