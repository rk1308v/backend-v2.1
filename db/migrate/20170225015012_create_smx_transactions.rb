class CreateSmxTransactions < ActiveRecord::Migration[6.1]
  def change
    create_table :smx_transactions do |t|
      t.decimal :amount,  null: false
      t.references :transactionable, polymorphic: true, index: {name: "index_smx_transactions_on_transactionable"} # Index name too long. Customizing index name

      t.timestamps
    end
  end
end
