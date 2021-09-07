class InviteNotification < ApplicationRecord

  # Relationships
  # No has_many counterpart defined because we dont anticipate accessing this model from user model
  belongs_to :notified_by, class_name: 'User'
  has_many :notifications, as: :noticeable
  
end
