class CreateSusuNotifications < ActiveRecord::Migration[6.1]
  def change
    create_table :susu_notifications do |t|
      t.integer :notice_type
      t.references :smx_transaction, foreign_key: true
      t.references :susu, foreign_key: true
      t.references :notified_by, foreign_key: {to_table: :users} # Custom solution to address the renaming of user to notified_by

      t.timestamps
    end
  end
end
