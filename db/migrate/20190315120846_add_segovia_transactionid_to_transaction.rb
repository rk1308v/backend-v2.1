class AddSegoviaTransactionidToTransaction < ActiveRecord::Migration[6.1]
  	def change
  		add_column :user_transactions, :segovia_transaction_id, :string, default: ''
  	end
end
