class UserAccount < ApplicationRecord
  serialize :descriptions, Array
  
  # Relationships
  has_one :account, as: :profile
  has_one :user, through: :account
  
end
