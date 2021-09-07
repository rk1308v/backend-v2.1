class CreateContactBooks < ActiveRecord::Migration[6.1]
  def change
    create_table :contact_books do |t|
      t.boolean :smx_user, default: false
      t.string :name
      t.string :telephone
      t.string :email
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
