class CreatePaymentServices < ActiveRecord::Migration[6.1]
  def change
    create_table :payment_services do |t|
      t.string :service_name
      t.string :api_key
      t.boolean :isactive
      t.text :service_description

      t.timestamps
    end
  end
end
