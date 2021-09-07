class RemoveEmailConfirmedFromUsers < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :email_confirmed, :string
  end
end
