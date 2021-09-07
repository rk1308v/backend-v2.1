class CreateAddresses < ActiveRecord::Migration[6.1]
  def change
    create_table :addresses do |t|
      t.string :line1
      t.string :line2
      t.string :line3
      t.string :city
      t.string :postcode_prefix
      t.string :zip_postcode
      t.string :state_province_county
      t.text :description
      t.integer :address_type
      t.references :user, foreign_key: true, null: false 

      t.timestamps
    end
  end
end
