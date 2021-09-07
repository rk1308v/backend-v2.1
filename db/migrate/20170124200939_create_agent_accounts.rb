class CreateAgentAccounts < ActiveRecord::Migration[6.1]
  def change
    create_table :agent_accounts do |t|
      t.string :company_name
      t.decimal :money_in,           default: 0
      t.decimal :money_out,          default: 0
      t.decimal :commission_earned,  default: 0
      t.decimal :payin_amount_due,   default: 0
      t.text :description
      t.references :user,      null: false,  foreign_key: true

      t.timestamps
    end
  end
end
