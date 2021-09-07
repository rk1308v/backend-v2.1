class CreateCountries < ActiveRecord::Migration[6.1]
  def change
    create_table :countries do |t|
      t.string :iso_alpha_3,   null: false
      t.string :name,          null: false
      t.boolean :transfer
      t.boolean :susu
      #t.boolean :bills

      t.timestamps
    end
  end
end
