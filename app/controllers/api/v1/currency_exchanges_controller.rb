class Api::V1::CurrencyExchangesController < Api::V1::BaseController
    before_action :set_currency_exchange, only: [:show, :update, :destroy]
    skip_before_action :authenticate_user_from_token!, :validate_api_key, :only => [:upload_effective_rates]

    def_param_group :currency do
        param :currency, Hash, required: true, action_aware: true do
            param :numerical_code, String, required: true, allow_nil: false
            param :value, /\A(\d+[\.,]?\d*|\d*[\.,]?\d+)\Z/, required: true, allow_nil: false
            #param :inverse_value, /\A(\d+[\.,]?\d*|\d*[\.,]?\d+)\Z/, required: true, allow_nil: false
            param :effective_date, DateTime, required: true, allow_nil: false
            param :active, [true, false], required: true, allow_nil: false
            param :country_from, String, required: true, allow_nil: false
            param :country_to, String, required: true, allow_nil: false
        end
    end

    #api :GET, '/currency_exchanges','List Currency Exchanges'
    def index
        @currency_exchanges = CurrencyExchange.page(params[:page]).per(params[:per])
        render json: @currency_exchanges
    end

    #api :GET, '/currency_exchanges/:id','Show Currency Exchange'
    def show
        render json: @currency_exchange
    end

    #api :POST, '/currency_exchanges','Create Currency Exchange'
    #param_group :currency
    def create
        @currency_exchange = CurrencyExchange.new(currency_exchange_params)
        if @currency_exchange.save
            render json: @currency_exchange, status: :created
        else
            render json: @currency_exchange.errors, status: :unprocessable_entity
        end
    end

    #api :PUT, '/currency_exchanges/:id','Update Currency Exchange'
    #param_group :currency
    def update
        if @currency_exchange.update(currency_exchange_params)
            render json: @currency_exchange
        else
            render json: @currency_exchange.errors, status: :unprocessable_entity
        end
    end

    #api :DELETE, '/currency_exchanges/:id','Destroy Currency Exchanges'
    def destroy
        @currency_exchange.destroy
    end

    def upload_effective_rates
        if params[:upload][:token].blank?
            render status: 422, json: {message: 'Token cannot be blank'}
        elsif params[:upload][:token] != 'L_rzk20CD7HIEua986jggw'
            render status: 422, json: {message: 'Token incorrect'}
        elsif params[:upload][:exchange_rate].blank?
            render status: 422, json: {message: 'File cannot be blank'}
        else
            name = params[:upload][:exchange_rate].original_filename
            path = File.join("public", "csv-exchange-rate", 'exchange-rate-1.xlsx')
            if File.open(path, "wb") { |f| f.write(params[:upload][:exchange_rate].read) }
                CurrencyExchange.setup_effective_exchange_rate
                render status: 200, json: {message: 'Data updated'}
            end
        end
        
    end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_currency_exchange
        @currency_exchange = CurrencyExchange.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def currency_exchange_params
        params.require(:currency_exchange).permit(:value, :effective_date, :active, :country_from, :country_to)
    end
end
