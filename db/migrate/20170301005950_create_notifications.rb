class CreateNotifications < ActiveRecord::Migration[6.1]
  def change
    create_table :notifications do |t|
      t.boolean :read
      t.string :notice
      t.references :user, foreign_key: true
      t.references :noticeable, polymorphic: true

      t.timestamps
    end
  end
end
