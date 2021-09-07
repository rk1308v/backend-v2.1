class CreateInviteNotifications < ActiveRecord::Migration[6.1]
  def change
    create_table :invite_notifications do |t|
      t.references :notified_by, foreign_key: {to_table: :users} # Custom solution to address the renaming of user to notified_by

      t.timestamps
    end
  end
end
