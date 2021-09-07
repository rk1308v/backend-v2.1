class PaymentMethod < ApplicationRecord

  serialize :descriptions, Array
  enum payment_type: [:debit, :credit, :bank]
  enum card_type: [:visa, :mastercard, :amex, :other]
 
  # Relationships
  belongs_to :country
  belongs_to :user
  
  # Autocode: Validations
  validates :country_id, presence: true
  validates :user_id, presence: true

end
