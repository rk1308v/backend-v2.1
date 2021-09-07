class Activity < ApplicationRecord
    
  	belongs_to :user
  	# No has_many counterpart defined because we dont anticipate accessing this model from smx_transaction model
  	# belongs_to :smx_transaction
  	
  	def send_receiver_notification
        transaction = UserTransaction.exists?(self.smx_transaction_id.to_i) ? self.user_transaction : nil
        if transaction.present?
            if transaction.recipient.fcm_token.present? && transaction.recipient.push_enabled == true
                options = {
                    "data": {
                        sender_id: transaction.sender_id,
                        sender_name: transaction.sender.full_name,
                        sender_telephone: transaction.sender.telephone,
                        amount: transaction.net_amount.to_f,
                        notice_type: 'send_',
                        notification_date: transaction.created_at
                    },
                    "notification" => {
                        "title" => "You got paid \u{1F911}",
                        "body" => self.activity
                    }
                }
                FirebaseService.new([transaction.recipient.fcm_token], options).send_notification
            end
        end
  	end

    def user_transaction
        return UserTransaction.find(self.smx_transaction_id)
    end

    def is_sent
        return self.activity.include? 'sent'
    end  	
end
