class CreateSusuMemberships < ActiveRecord::Migration[6.1]
  def change
    create_table :susu_memberships do |t|
      t.boolean :admin
      t.boolean :collected
      t.integer :last_payin_round,   default: 0
      t.integer :payout_round,       default: 0
      t.text :description
      t.references :user, foreign_key: true, null: false
      t.references :susu, foreign_key: true, null: false

      t.timestamps
    end
  end
end
