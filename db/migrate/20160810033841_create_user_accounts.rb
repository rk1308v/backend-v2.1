class CreateUserAccounts < ActiveRecord::Migration[6.1]
  def change
    create_table :user_accounts do |t|
      t.decimal :balance, default: 0
      t.decimal :single_send_limit
      t.decimal :monthtly_send_limit
      t.text :description
      #t.references :currency, null: false, foreign_key: true

      t.timestamps
    end
  end
end
