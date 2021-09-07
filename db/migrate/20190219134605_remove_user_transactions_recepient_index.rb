class RemoveUserTransactionsRecepientIndex < ActiveRecord::Migration[6.1]
  def change
    change_column_null :user_transactions, :recipient_id, true
  end
end
