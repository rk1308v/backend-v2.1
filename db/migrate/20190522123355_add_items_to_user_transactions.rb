class AddItemsToUserTransactions < ActiveRecord::Migration[6.1]
  	def change
  		add_column :user_transactions, :payment_processor_fees, :decimal, :null => false, :default => '0'
  		add_column :user_transactions, :payment_processor_fees_percentage, :float
  		add_column :user_transactions, :payout_service, :string, default: ''
  		add_column :user_transactions, :payment_method, :string, default: ''
  	end
end
