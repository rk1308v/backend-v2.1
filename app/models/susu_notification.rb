class SusuNotification < ApplicationRecord
  enum notice_type: [:invited_, :joined_, :due_date_, :payout_, :late_, :late_fee_]
 
  # Relationships
  
  #### To be uncommented when Heroku supports "Optional" ####
  # belongs_to :smx_transaction
  
  belongs_to :susu
  # No has_many counterpart defined because we dont anticipate accessing this model from user model
  belongs_to :notified_by, class_name: 'User'
  has_many :notifications, as: :noticeable
  
end
