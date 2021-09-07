class AddResponseHashToUserTransactions < ActiveRecord::Migration[6.1]
  	def change
  		add_column :user_transactions, :response_hash, :text
  	end
end
