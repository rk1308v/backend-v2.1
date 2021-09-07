class SusuMembership < ApplicationRecord
  
  serialize :descriptions, Array
  
  # Relationships
  belongs_to :user
  belongs_to :susu
  
  # Validations
  validates :susu_id, presence: true
  validates :user_id, presence: true
  validates :susu_id, uniqueness: {scope: [:user_id], message: 'You are already added to Susu '}

end
