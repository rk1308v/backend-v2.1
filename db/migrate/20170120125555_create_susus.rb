class CreateSusus < ActiveRecord::Migration[6.1]
  def change
    create_table :susus do |t|
      t.string :name
      t.integer :members_count,  null: false
      t.integer :rounds_count
      t.integer :current_round,  default: 0
      t.integer :days_per_round, null: false
      t.decimal :payin_amount,   null: false
      t.decimal :payout_amount,  null: false
      t.decimal :fees,           null: false
      t.datetime :started_at,    null: false
      t.datetime :ended_at
      t.integer :status,         null: false
      t.text :description

      t.timestamps
    end
  end
end
