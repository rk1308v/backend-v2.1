class AddFieldsUsers < ActiveRecord::Migration[6.1]
  def change
    rename_column :users,:verified,:phone_verified
    add_column :users,:email_verified,:boolean, default: false 
  end
end
