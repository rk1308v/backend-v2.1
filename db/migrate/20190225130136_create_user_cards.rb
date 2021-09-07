class CreateUserCards < ActiveRecord::Migration[6.1]
  def change
    create_table :user_cards do |t|
      t.references :user, foreign_key: true
      t.string :card_token

      t.timestamps
    end
  end
end
