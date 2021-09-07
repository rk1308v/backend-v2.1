class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :telephone, unique: true
      t.boolean :active    
      t.string :country, null: false   # ISO Alpha 3
      t.integer :rank
      t.text :description

      t.timestamps
    end
  end
end
