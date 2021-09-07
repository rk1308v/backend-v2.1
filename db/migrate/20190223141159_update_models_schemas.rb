class UpdateModelsSchemas < ActiveRecord::Migration[6.1]
    def change
        add_column :currency_exchanges, :effective_exchange_rate, :decimal, default: 0.0
        rename_column :user_transactions, :smx_trans, :recipient_type
    end
end
