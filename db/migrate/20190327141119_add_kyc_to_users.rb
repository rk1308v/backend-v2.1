class AddKycToUsers < ActiveRecord::Migration[6.1]
  	def change
  		add_column :users, :kyc_document, :string, default: ''
  		add_column :users, :kyc_verified, :boolean, default: false
  	end
end
