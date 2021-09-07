class AddTransactionTypeToUserTransactions < ActiveRecord::Migration[6.1]
  	def change
  		rename_column :user_transactions, :segovia_transaction_id, :api_transaction_id
  		add_column :user_transactions, :transaction_api, :string, default: ''
  		add_column :user_transactions, :job_id, :string, default: ''
  	end
end
