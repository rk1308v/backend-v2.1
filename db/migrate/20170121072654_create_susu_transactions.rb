class CreateSusuTransactions < ActiveRecord::Migration[6.1]
  def change
    create_table :susu_transactions do |t|
      t.decimal :net_amount,   null: false
      t.decimal :fees,         null: false
      t.integer :round,        null: false
      t.integer :trans_type,   null: false
      t.integer :payment_type, null: false
      t.integer :status,       null: false
      t.text :description
      t.references :susu,      null: false,  foreign_key: true
      t.references :user,      null: false,  foreign_key: true

      t.timestamps
    end
  end
end
