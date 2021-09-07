require 'securerandom'
require 'uri'
require 'net/http'
require 'net/https'
require 'json'

class TransactionStatusWorker
    include Sidekiq::Worker
    sidekiq_options retry: true
    
    def perform(user_transaction_id)
        UserTransaction.transaction do
            user_transaction = UserTransaction.find(user_transaction_id)
            sender = user_transaction.sender
            sender_account = sender.account.profile
            formatted_amount = sender.get_formatted_amount(user_transaction.net_amount, user_transaction.country_to)

            if user_transaction.status == SmxTransaction.statuses[:pending_]
                if user_transaction.recipient_type == SmxTransaction.recipient_types[:international_recep_]
                    net_amount = user_transaction.net_amount
                    total_amount = net_amount + user_transaction.fees
                    sender_account.update!(balance: sender_account.reload.balance + total_amount)
                    user_transaction.update(status: SmxTransaction.statuses[:cancelled_])
                    user_transaction.refund_charge
                elsif user_transaction.recipient_type == SmxTransaction.recipient_types[:non_smx_recep_]
                    user_transaction.update(status: SmxTransaction.statuses[:cancelled_])
                    SmsService.new({phone_number: user_transaction.sender.telephone, first_name: user_transaction.response_hash[:recipient_first_name].capitalize, last_name: user_transaction.response_hash[:recipient_last_name], formatted_amount: formatted_amount}, SmxTransaction.message_types[:smx_non_smx_cancelled_send_])
                end
            end
        end
    end
end