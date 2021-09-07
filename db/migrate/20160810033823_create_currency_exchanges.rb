class CreateCurrencyExchanges < ActiveRecord::Migration[6.1]
  def change
    create_table :currency_exchanges do |t|
      t.decimal :value
      #t.decimal :inverse_value
      t.timestamp :effective_date
      t.boolean :active
      t.string :country_from,  index: true,  null: false  #foreign_key: {to_table: :currencies}
      t.string :country_to,    index: true,  null: false  #foreign_key: {to_table: :currencies}

      t.timestamps
    end
  end
end
