class SusuTransaction < ApplicationRecord
  include GlobalEnums
  serialize :descriptions, Array

  # Relationships
  belongs_to :susu
  belongs_to :user
  has_many :smx_transactions, as: :transactionable
  #has_many :users, through: :transactions

  # Validations
  validates :net_amount, presence: true
  validates :fees, presence: true
  validates :round, presence: true
  validates :trans_type, presence: true, inclusion: { in: %w(payin_ payout_ penalty_), message: "%{value} is not a valid trans_type"}
  #validates :trans_type, presence: true, inclusion: { in: 4..6, message: "%{value} is not a valid trans_type"}
  validates :payment_type, presence: true, inclusion: { in: %w(smx_ electronic_), message: "%{value} is not a valid payment_type"}
  #validates :payment_type, presence: true, inclusion: { in: 1..2, message: "%{value} is not a valid trans_type"}
  validates :status, presence: true, inclusion: { in: %w(pending_ cancelled_ complete_), message: "%{value} is not a valid payment_type"}
  validates :susu_id, presence: true
  validates :user_id, presence: true
  
end
