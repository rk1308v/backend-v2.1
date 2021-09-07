class AddRecepientTelephoneToUserTransactions < ActiveRecord::Migration[6.1]
  def change
    add_column :user_transactions, :recipient_telephone, :string, default: ''
    add_column :user_transactions, :smx_trans, :integer, default: 1
  end
end
