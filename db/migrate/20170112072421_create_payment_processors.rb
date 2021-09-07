class CreatePaymentProcessors < ActiveRecord::Migration[6.1]
  def change
    create_table :payment_processors do |t|
      t.string :name
      t.string :username
      t.string :password
      t.references :country, foreign_key: true, null: false

      t.timestamps
    end
  end
end
