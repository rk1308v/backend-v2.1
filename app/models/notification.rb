class Notification < ApplicationRecord
  	# Relationships
  	belongs_to :user  # No has_many counterpart defined because we dont anticipate accessing this model from user model
  	belongs_to :noticeable, polymorphic: true
  	
  	def send_request_notification
        if self.user.fcm_token.present? && self.user.push_enabled == true
            if self.noticeable.present?
                options = {
                    "data": {
                        sender_id: self.noticeable.notified_by_id,
                        sender_name: self.noticeable.notified_by.full_name,
                        sender_telephone: self.noticeable.notified_by.telephone,
                        amount: self.noticeable.amount.to_f,
                        notice_type: self.noticeable.notice_type,
                        notification_date: self.noticeable.created_at
                    },
                    "notification" => {
                        "title" => "Pay Request",
                        "body" => self.notice
                    }
                }
                FirebaseService.new([self.user.fcm_token], options).send_notification
            end
        end
    end
  	
end
