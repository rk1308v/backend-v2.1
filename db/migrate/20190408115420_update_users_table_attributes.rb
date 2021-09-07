class UpdateUsersTableAttributes < ActiveRecord::Migration[6.1]
  	def change
  		rename_column :user_transactions, :api_transaction_id, :transaction_id
  		rename_column :user_transactions, :transaction_api, :transaction_service
  		add_index :user_transactions, :transaction_id
  		add_index :user_transactions, :transaction_service
  	end
end
