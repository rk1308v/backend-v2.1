class CreateFeesAndCommissions < ActiveRecord::Migration[6.1]
  def change
    create_table :fees_and_commissions do |t|
      t.decimal :amount_from
      t.decimal :amount_to
      t.decimal :amount
      t.decimal :percentage
      t.boolean :percent_based,         null: false
      t.boolean :active
      t.integer :fc_type
      t.integer :rank
      t.integer :money_type
      t.integer :tansaction_type
      t.references :sending_country,    null: false,  foreign_key: {to_table: :countries} # Custom solution to address the renaming of country to sending country
      t.references :receiving_country,  null: false,  foreign_key: {to_table: :countries} # Custom solution to address the renaming of country to receiving country

      t.timestamps
    end
  end
end
