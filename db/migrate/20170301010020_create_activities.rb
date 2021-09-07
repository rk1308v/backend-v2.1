class CreateActivities < ActiveRecord::Migration[6.1]
  def change
    create_table :activities do |t|
      t.string :activity
      t.decimal :amount
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
