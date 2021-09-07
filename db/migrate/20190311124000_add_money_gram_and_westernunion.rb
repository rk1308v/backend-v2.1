class AddMoneyGramAndWesternunion < ActiveRecord::Migration[6.1]
  def change
    add_column :currency_exchanges, :money_gram_rate, :float, default: 0.0
    add_column :currency_exchanges, :western_union_rate, :float, default: 0.0
  end
end
