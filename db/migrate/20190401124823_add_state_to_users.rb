class AddStateToUsers < ActiveRecord::Migration[6.1]
  	def change
  		add_column :users, :registration_state, :string, default: ''
  		add_column :users, :registration_ip, :string, default: ''
  	end
end
