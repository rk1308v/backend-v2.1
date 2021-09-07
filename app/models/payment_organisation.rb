class PaymentOrganisation < ApplicationRecord
    belongs_to :country
    enum termination_type: ['Mobile Wallet', 'Bank', 'Cash Pickup']

    def payout_service_fees
		return 0.0
	end
end
