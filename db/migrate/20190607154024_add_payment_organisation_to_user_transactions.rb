class AddPaymentOrganisationToUserTransactions < ActiveRecord::Migration[6.1]
  def change
  	add_column :user_transactions, :payment_organisation_id, :integer
  end
end
