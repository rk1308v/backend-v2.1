class Api::V1::AgentAccountsController < Api::V1::BaseController
    skip_before_action :authenticate_user_from_token!, :only => [:create_agent, :validate_signup_params]
    #before_action :set_agent_account, only: [:show, :update, :destroy]

    def_param_group :agent_account do
        param :agent_account, Hash, required: true, action_aware: true do
            param :company_name, String, required: true, allow_nil: false
            param :money_in, /\A(\d+[\.,]?\d*|\d*[\.,]?\d+)\Z/, required: true, allow_nil: false
            param :money_out, /\A(\d+[\.,]?\d*|\d*[\.,]?\d+)\Z/, required: true, allow_nil: false
            param :commission_earned, /\A(\d+[\.,]?\d*|\d*[\.,]?\d+)\Z/, required: true, allow_nil: false
            param :payin_amount_due, /\A(\d+[\.,]?\d*|\d*[\.,]?\d+)\Z/, required: true, allow_nil: false
            param :description, String, required: true, allow_nil: false
            #param :currency_id, Integer, required: true, allow_nil: false
        end
    end

    ####################################################
    # Create a agent and create  authtoken token
    ####################################################
    api :POST, '/signup','Create an agent'
    param_group :agent_account
    def create_agent
        country = ISO3166::Country.find_country_by_name(agent_params[:country])
        if country
            params[:agent_account][:country] = country.alpha3.downcase
        else
            @message = "Invalid country name '#{agent_params[:country]}'"
            log_info
            render status: 400, json: {status: 400, error: @message}
            puts @message
            return
        end 
        @user = User.new agent_params
        @user.set_agent_role
        @username = GenerateUsernameService.new("ag#{@user.first_name.downcase}.#{@user.last_name.downcase}")
        @user.username =  @username.set_username
        ActiveRecord::Base.transaction do
            if @user.save
                send_registration_confirmation_email #send_confirmation_email # Send email confirmation mail to user
                Account.create_agent_account @user, agent_account_params # Create acccount
                Picture.create!(user_id: @user.id) # Create profile picture
                create_address
                @auth_token = Authtoken.create_auth_token(@user.id,request.remote_ip, request.user_agent, params[:device_id])
                render json: {username: "#{@user.username}", message: "Your account was succesfully created", auth_token: @auth_token.token}
            else
                @message = @user.error_message
                log_info
                render status: 400, json: {status: 400, error: @message}
            end
        end
    end

    ####################################################
    # Get agents address list
    ####################################################
    api :GET, '/agent_account','Get agents address list'
    param_group :agent_account
    def agent_addresses
        agents = User.where(role: User.roles[:agent_], country: @user.country)
                  .as_json({only: :telephone,
                            methods: [:agent_account],
                            include: [addresses: {include: [country: {only: :name}]}]
                  })

        agents_list = []
        agents.each do |agent| 
            name = agent['agent_account'].company_name
            telephone = agent['telephone']
            addresses = agent['addresses']
            addresses.each do |addr|
                line  = addr['line1']
                line += " " + addr['line2'] if addr['line2'].present?
                line += " " + addr['line3'] if addr['line3'].present?
                city = addr['city']
                zip_postcode = addr['zip_postcode']
                country = addr['country']['name']
                agents_list << {name: name,
                            street: line,
                            city: city,
                            zip_code: zip_postcode,
                            country: country,
                            telephone: telephone
                        }
                end
            end
        render json: {addresses: agents_list}
    end 

    # #api :GET, '/agent_accounts', 'List Agent Accounts'
    def index
        render status: 404
        return
        @agent_accounts = AgentAccount.page(params[:page]).per(params[:per])
        render json: @agent_accounts
    end

    # #api :GET, '/agent_accounts/:id', 'Show Agent Account'
    # def show
    #   render json: @agent_account
    # end

    # #api :POST, '/agent_accounts', 'Create Agent Account'
    # #param_group :agent_account
    # def create
    #   @agent_account = AgentAccount.new(agent_account_params)

    #   if @agent_account.save
    #     render json: @agent_account, status: :created, location: @agent_account
    #   else
    #     render json: @agent_account.errors, status: :unprocessable_entity
    #   end
    # end

    # #api :PUT, '/agent_accounts/:id', 'Update Agent Account'
    # #param_group :agent_account
    # def update
    #   if @agent_account.update(agent_account_params)
    #     render json: @agent_account
    #   else
    #     render json: @agent_account.errors, status: :unprocessable_entity
    #   end
    # end

    # #api :DELETE, '/agent_accounts/:id', 'Destroy Agent Account'
    # def destroy
    #   @agent_account.destroy
    # end

    private
    # Use callbacks to share common setup or constraints between actions.
    def log_info
        puts "----------- Response (Agent Account) -------------"
        logger.info @message
        puts "--------------------------------------------------" 
    end

    def send_registration_confirmation_email
        @user.set_email_token
        @user.save(validate: false) 
        UserMailer.registration_confirmation(@user).deliver_now
    end 

    def create_address
        address_type = agent_address_params[:address_type]
        params[:agent_account][:address_type] = Address.address_types[address_type.to_sym]
        params_copy = agent_address_params
        params_copy[:description] = params_copy.delete :addr_description
        country = Country.find_by_iso_alpha_3(@user.country)
        addr = Address.new params_copy
        addr.user_id = @user.id
        addr.country_id = country.id
        addr.save!
    end

    def set_agent_account
        @agent_account = AgentAccount.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def agent_params
        params.require(:agent_account).permit(:first_name, :last_name, :email, :password, :password_confirmation, :country, :device_id, :username, :telephone)
    end

    def agent_account_params
        params.require(:agent_account).permit(:company_name, :money_in, :money_out, :commission_earned, :payin_amount_due, :account_description)
    end

    def agent_address_params
        params.require(:agent_account).permit(:line1, :line2, :line3, :city, :postcode_prefix, :zip_postcode, :addr_description, :address_type)
    end

end
