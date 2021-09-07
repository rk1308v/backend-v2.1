class CreateAgentTransactions < ActiveRecord::Migration[6.1]
  def change
    create_table :agent_transactions do |t|
      t.decimal :net_amount,    null: false
      t.decimal :fees,          null: false
      t.decimal :commission,    null: false
      t.integer :trans_type,    null: false
      t.integer :payment_type,  null: false
      t.integer :status,        null: false
      t.text :description
      t.references :user,  foreign_key: {to_table: :users} # Custom solution to address the renaming of user to user
      t.references :agent,  null: false,  foreign_key: {to_table: :users} # Custom solution to address the renaming of user to agent
       
      t.timestamps
    end
  end
end
