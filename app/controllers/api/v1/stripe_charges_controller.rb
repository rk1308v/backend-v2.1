class Api::V1::StripeChargesController < Api::V1::BaseController 

    def_param_group :user_charge do
        param :user_charge, Hash, required: true, action_aware: true do
            param :amount, Float, required: true, allow_nil: false
            param :stripe_token, String, required: true, allow_nil: false
        end
    end

    api :POST, '/create_card', 'Create card of user'
    param_group :user_charge
    def create_card
        if @user.stripe_customer_id.present?
            begin
                card = Stripe::Customer.create_source(@user.stripe_customer_id, { source: user_charge_params[:card_token]})
                if card
                    render status: 200, json: {status: 200, error: '', card: card, message: 'Card is added successfully'}
                else
                    render status: 400, json: {status: 400, error: '', card: card, error: 'There was a problem adding card'}
                    TransactionlogService.new(params, 'Adding card to stripe failed', 400).fatal
                end
            rescue => e
                render status: 400, json: {status: 400, error: '', card: card, error: "There was a problem adding card: #{e}"}
                TransactionlogService.new(params, 'Adding card to stripe failed', 400).fatal
            end
        else
            render status: 412, json: {status: 412, error: 'User is not a stripe customer'}
        end
    end

    api :POST, '/delete_card', 'Delete card of user'
    param_group :user_charge
    def delete_card
        if @user.stripe_customer_id.present?
            begin
                card = Stripe::Customer.delete_source(@user.stripe_customer_id, user_charge_params[:card_token])
                if card["deleted"] == true
                    render status: 200, json: {status: 200, error: '', card: card, message: 'Card deleted successfully' }
                else
                    render status: 400, json: {status: 400, error: '', card: card, error: 'There was a problem deleting card'}
                    TransactionlogService.new(params, 'Deleting card to stripe failed', 400).fatal
                end
            rescue => e
                render status: 400, json: {status: 400, error: '', card: card, error: "There was a problem adding card: #{e}"}
                TransactionlogService.new(params, 'Adding card to stripe failed', 400).fatal
            end
        else
            render status: 412, json: {status: 412, error: 'User is not a stripe customer'}
        end
    end

    api :POST, '/get_cards', 'Get cards of user'
    param_group :user_charge
    def get_cards
        if @user.stripe_customer_id.present?
            sources = Stripe::Customer.list_sources(@user.stripe_customer_id)
            render status: 200, json: {status: 200, error: '', cards: sources }
        else
            render status: 412, json: {status: 412, error: 'User is not a stripe customer'}
        end
    end

    api :POST, '/create_stripe_customer', 'Add customer to stripe'
    param_group :user_charge
    def create_stripe_customer
        if @user.stripe_customer_id.present?
            render status: 200, json: {status: 200, error: '', message: 'User already added to stripe', customer_token: @user.stripe_customer_id }
        else
            @cust_token = user_charge_params[:src_token]
            @registration = register_user_with_stripe
            if @registration
                @user.update(stripe_customer_id: @registration['id'])
                render status: 200, json: {status: 200, error: '', message: 'User added to stripe', customer_token: @registration['id']}
            else
                render status: 412, json: {status: 412, error: 'Something went wrong. Please try again'}
                TransactionlogService.new(params, 'Failed to add user to stripe', 400).fatal
            end
        end
    end

    api :POST, '/load_money', 'Add money to Stripe account'
    param_group :user_charge
    def load_money
        @amount = user_charge_params[:amount].to_f
        @stripe_token = @user.stripe_customer_id
        @source = user_charge_params[:source]
        @user_country = UserTransaction.new.iso_country(@user.country)
        @user_currency_code = @user_country.currency.iso_code
        begin
            puts 'Beginning charging'
            @charge = Stripe::Charge.create({
                customer: @user.stripe_customer_id,
                amount: @amount.to_i * 100,
                source: @source,
                currency: @user_currency_code
            })
            puts "Charge: #{@charge}"
            if @charge
                @user.user_charges.create(charge_token: @charge['id'])
                render status: 200, json: {status: 200, error: '', message: 'Charged successfully'}
            else
                puts "Charge: #{@charge}"
                TransactionlogService.new(params, 'There was a problem charging source. Please try again', 400).fatal
                render status: 412, json: {status: 412, error: 'There was a problem charging source. Please try again'}
            end
        rescue => e
            puts("Error: #{e}")
            TransactionlogService.new(params, 'There was a problem charging source. Please try again', 400).fatal
            render status: 412, json: {status: 412, error: 'There was a problem charging source. Please try again'}
        end
    end

    private
    def register_user_with_stripe
        StripeChargesService.new({
            source: @cust_token,
            email: @user.email
        }).create_customer
    end

    def user_charge_params
        params.require(:user).permit(:amount, :stripe_token, :card_token, :src_token, :source)
    end

    def validate_params
        if @amount.to_f <= 0
            return 'Amount cannot be blank'
        elsif @stripe_token.blank?
            return 'Please register user as stripe customer first'
        end
    end
end