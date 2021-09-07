class CreateSusuInvites < ActiveRecord::Migration[6.1]
  def change
    create_table :susu_invites do |t|
      t.boolean :accepted,      default: false
      t.references :susu,       null: false,  foreign_key: true
      t.references :sender,     null: false,  foreign_key: {to_table: :users} # Custom solution to address the renaming of user to sender
      t.references :recipient,  null: false,  foreign_key: {to_table: :users} # Custom solution to address the renaming of user to recipient

      t.timestamps
    end
  end
end
