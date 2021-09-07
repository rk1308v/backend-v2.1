class AddTransactionStripeChargeToUserTransactions < ActiveRecord::Migration[6.1]
  	def change
  		add_column :user_transactions, :stripe_charge, :string, default: ''
  	end
end
