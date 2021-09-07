class Api::V1::AddressesController < Api::V1::BaseController
    before_action :set_address, only: [:show, :update, :destroy]
    before_action :set_user, only: [:create, :index]

    def_param_group :address do
        param :address, Hash, required: true, action_aware: true do
            param :line1, String, required: true, allow_nil: false
            param :line2, String, required: true, allow_nil: false
            param :line3, String, required: true, allow_nil: false
            param :city, String, required: true, allow_nil: false
            param :postcode_prefix, String, required: true, allow_nil: false
            param :zip_postcode, String, required: true, allow_nil: false
            param :state_province_county, String, required: true, allow_nil: false
            param :description, String, required: true, allow_nil: false
            param :address_type, Integer, required: true, allow_nil: false
            param :country_id, String, required: true, allow_nil: false
        end
    end

    #api :GET, '/addresses', 'List Addresses'
    def index
        @addresses = @user.addresses.page(params[:page]).per(params[:per])
        render json: @addresses
    end

    #api :GET, '/addresses/:id','Show Address'
    def show
        render json: @address
    end

    #api :POST, '/addresses','Create Address'
    #param_group :address
    def create
        @address = @user.addresses.new(address_params)
        if @address.save
            render json: @address, status: :created
        else
            render json: @address.errors, status: :unprocessable_entity
        end
    end

    #api :PUT, '/addresses/:id','Update Address'
    #param_group :address
    def update
        if @address.update(address_params)
            render json: @address
        else
            render json: @address.errors, status: :unprocessable_entity
        end
    end

    #api :DELETE, '/addresses/:id','Destroy Address'
    def destroy
        if @address
            @address.destroy
        else
            render json: {code: 400, error: "Address not present"}
        end
    end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
        @user = Authtoken.find_by(token: params[:auth_token]).user
    end

    def set_address
        @address = Address.find_by(:id => params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def address_params
        params.require(:address).permit(:line1, :line2, :line3, :city, :postcode_prefix, :zip_postcode, :state_province_county, :description, :address_type, :country_id)
    end
end
