class CreateUserCharges < ActiveRecord::Migration[6.1]
  def change
    create_table :user_charges do |t|
      t.references :user, foreign_key: true
      t.string :charge_token

      t.timestamps
    end
  end
end
