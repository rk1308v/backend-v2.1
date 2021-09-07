require 'stripe'

class StripeChargesService
    def initialize(params)
        @card = params[:card]
        @amount = params[:amount]
        @email = params[:email]
        @stripe_token = params[:customer]
        @source = params[:source]
    end

    def charge
        begin
            external_charge_service.create(charge_attributes)
        rescue
            false
        end
    end

    def create_customer
        begin
            external_customer_service.create(customer_attributes)
        rescue
            false
        end
    end

    def update_stripe_customer
        customer = external_customer_service.retrieve(@stripe_token)
        customer.email = @email
        customer.save
    end

    private

    attr_reader :customer, :amount, :email, :stripe_token, :source

    def card_fees
        # return 3% of amount
    end

    def external_charge_service
        Stripe::Charge
    end

    def external_customer_service
        Stripe::Customer
    end

    def charge_attributes
        {
            amount: @amount,
            customer: @stripe_token,
            currency: 'usd',
            source: @source
        }
    end

    def customer_attributes
        {
            email: email,
            source: @source
        }
    end

end