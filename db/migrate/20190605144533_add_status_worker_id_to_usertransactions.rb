class AddStatusWorkerIdToUsertransactions < ActiveRecord::Migration[6.1]
  	def change
  		add_column :user_transactions, :status_worker_job_id, :string, default: ''
  	end
end
