class AgentTransaction < ApplicationRecord
  include GlobalEnums
  serialize :descriptions, Array

  # Relationships
  belongs_to :user #, optional: true
  belongs_to :agent, class_name: 'User'
  has_many :smx_transactions, as: :transactionable

  # Validations
  validates :net_amount, presence: true
  validates :fees, presence: true
  validates :commission, presence: true
  validates :agent_id, presence: true
  validates :trans_type, presence: true, inclusion: { in: %w(cashin_, cashout_, payin_, payout_), message: "%{value} is not a valid trans_type"}
  #validates :trans_type, presence: true, inclusion: { in: 0..1, message: "%{value} is not a valid trans_type"}
  validates :payment_type, presence: true, inclusion: { in: %w(cash_ electronic_), message: "%{value} is not a valid payment_type"}
  #validates :payment_type, presence: true, inclusion: { in: [0,2], message: "%{value} is not a valid trans_type"}
  validates :status, presence: true, inclusion: { in: %w(pending_ cancelled_ complete_), message: "%{value} is not a valid payment_type"}
  
end

