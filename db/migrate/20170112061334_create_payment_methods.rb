class CreatePaymentMethods < ActiveRecord::Migration[6.1]
  def change
    create_table :payment_methods do |t|
      t.string :issuer_name
      t.boolean :valid
      t.string :token
      t.datetime :token_valid_until
      t.integer :payment_type
      t.integer :card_type
      t.text :description
      t.references :country, foreign_key: true, null: false
      t.references :user, foreign_key: true,    null: false

      t.timestamps
    end
  end
end
