class AddFirebaseTokensToUserdevices < ActiveRecord::Migration[6.1]
  	def change
  		add_column :users, :fcm_token, :string, default: ''
  		add_column :users, :apns_token, :string, default: ''
  		add_column :users, :push_enabled, :boolean, default: false
  	end
end
