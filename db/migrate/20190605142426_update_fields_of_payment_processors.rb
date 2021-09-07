class UpdateFieldsOfPaymentProcessors < ActiveRecord::Migration[6.1]
  	def change
  		remove_column :payment_processors, :username
  		remove_column :payment_processors, :password
  		add_column :payment_processors, :api_key, :string, default: ''
  		add_column :payment_processors, :api_secret, :string, default: ''
  		add_column :payment_processors, :is_live, :boolean, default: true
  	end
end
