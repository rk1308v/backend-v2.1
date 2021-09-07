class AgentAccount < ApplicationRecord

  serialize :descriptions, Array
  
  # Relationships
  has_one :account, as: :profile
  has_one :user, through: :account
  
  # Validations
  validates :user_id, presence: true

end
