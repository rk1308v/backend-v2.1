class CreateAdminTransactions < ActiveRecord::Migration[6.1]
  def change
    create_table :admin_transactions do |t|
      t.decimal :amount,       null: false
      t.integer :trans_type,   null: false
      t.integer :status,        null: false
      t.text :description
      t.references :admin, foreign_key: {to_table: :users} # Custom solution to address the renaming of user to admin
      t.references :recipient, null: false, foreign_key: {to_table: :users} # Custom solution to address the renaming of user to recipient
      t.timestamps
    end
  end
end
