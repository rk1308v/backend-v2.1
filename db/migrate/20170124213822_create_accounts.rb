class CreateAccounts < ActiveRecord::Migration[6.1]
  def change
    create_table :accounts do |t|
      t.references :user, foreign_key: true, null: false
      t.references :profile, polymorphic: true

      t.timestamps
    end
  end
end
