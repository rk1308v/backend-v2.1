class AdminTransaction < ApplicationRecord
  include GlobalEnums
  serialize :descriptions, Array

  # Relationships
  belongs_to :recipient, class_name: 'User' 
  belongs_to :admin, class_name: 'User'
  has_many :smx_transactions, as: :transactionable    
  
  # Validations
  validates :amount, presence: true
  validates :recipient_id, presence: true
  validates :admin_id, presence: true # optional: true
  validates :trans_type, presence: true, inclusion: { in: %w(credit_, reversal_), message: "%{value} is not a valid trans_type"}
  #validates :trans_type, presence: true, inclusion: { in: 0..1, message: "%{value} is not a valid trans_type"}
  validates :status, presence: true, inclusion: { in: %w(pending_ cancelled_ complete_), message: "%{value} is not a valid payment_type"}

end
