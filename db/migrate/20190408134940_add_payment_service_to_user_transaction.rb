class AddPaymentServiceToUserTransaction < ActiveRecord::Migration[6.1]
  	def change
  		add_column :user_transactions, :payment_service_id, :integer
  		add_index :user_transactions, :payment_service_id
  	end
end
