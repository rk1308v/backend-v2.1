class CreatePaymentOrganisations < ActiveRecord::Migration[6.1]
    def change
        create_table :payment_organisations do |t|
            t.references :country, foreign_key: true
            t.string :service_name
            t.string :name
            t.integer :termination_type
            t.string :service_coverage
            t.string :availability
            t.string :business_model
            t.string :payment_speed
            t.float :max_transaction_amount
            t.string :benificiary_lookup
            t.decimal :commission_less_hundred
            t.decimal :commission_greater_hundred
            t.decimal :min_commission
            t.timestamps
        end
    end
end
