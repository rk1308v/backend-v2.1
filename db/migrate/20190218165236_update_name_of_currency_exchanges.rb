class UpdateNameOfCurrencyExchanges < ActiveRecord::Migration[6.1]
  def change
    remove_index :currency_exchanges, :country_from
    remove_index :currency_exchanges, :country_to
    rename_column :currency_exchanges, :country_from, :currency_from
    rename_column :currency_exchanges, :country_to, :currency_to
    add_index :currency_exchanges, :currency_from
    add_index :currency_exchanges, :currency_to
  end
end
