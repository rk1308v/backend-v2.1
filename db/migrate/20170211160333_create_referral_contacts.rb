class CreateReferralContacts < ActiveRecord::Migration[6.1]
  def change
    create_table :referral_contacts do |t|
      t.string :phone_number
      t.boolean :open_lead, default: true
      t.integer :reminder_count, default: 0
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
