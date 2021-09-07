class SusuInvite < ApplicationRecord

  # Relationships
  belongs_to :susu
  belongs_to :sender, class_name: 'User'
  belongs_to :recipient, class_name: 'User'
  
  # Validations
  validates :susu_id, presence: true
  validates :sender_id, presence: true
  validates :recipient_id, presence: true

end
