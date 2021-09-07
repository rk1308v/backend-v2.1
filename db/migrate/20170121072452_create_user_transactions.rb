class CreateUserTransactions < ActiveRecord::Migration[6.1]
    def change
        create_table :user_transactions do |t|
            t.decimal :net_amount,    null: false
            t.decimal :fees,          null: false
            t.decimal :exchange_rate, null: false
            t.string :country_from,   null: false
            t.string :country_to,     null: false
            t.integer :trans_type,    null: false
            t.integer :payment_type,  null: false
            t.integer :status,        null: false
            t.text :description
            t.references :sender,     null: false,  foreign_key: {to_table: :users}
            t.references :recipient,  null: false,  foreign_key: {to_table: :users}
            t.timestamps
        end
        if Rails.env == 'production'
            execute("ALTER TABLE user_transactions AUTO_INCREMENT = 51284")
        else
            execute("ALTER SEQUENCE user_transactions_id_seq START with 51284 RESTART;")
        end
    end
end
