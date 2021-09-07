class AddPinPinSentAtToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :pin, :integer
    add_column :users, :pin_sent_at, :datetime
  end
end
