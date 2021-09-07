class AddStatusAndSmxTransactionIdToActivities < ActiveRecord::Migration[6.1]
  def change
    add_column :activities, :status, :integer
    add_column :activities, :smx_transaction_id, :integer
  end
end
