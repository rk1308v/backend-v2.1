require 'securerandom'
require 'uri'
require 'net/http'
require 'net/https'
require 'json'

class SegoviaResponseWorker
    include Sidekiq::Worker
    sidekiq_options retry: true
    
    def perform(params)
        UserTransaction.transaction do
            puts params['transactions']
            params['transactions'].each do |transaction|
                trans_id = transaction['transactionId']
                puts "transaction: #{transaction}"
                statusCode = transaction['statusCode']
                transactionType = transaction['transactionType']
                statusType = transaction['statusType']
                user_transaction = UserTransaction.find_by(transaction_id: trans_id)
                if statusCode == 200 && transactionType == 'pay' && statusType == 'succeeded'
                    if user_transaction
                        @sender = user_transaction.sender
                        @recipient = user_transaction.recipient

                        @sender_account = @sender.account.profile
                        @recipient_account = @recipient.present? ? @recipient.account.profile : nil

                        @net_amount = user_transaction.net_amount #10$
                        @total_amount = @net_amount + user_transaction.fees #11$
                        @sent_to_recipient = @net_amount #$10

                        @exchange_rate = 1

                        ActiveRecord::Base.transaction do
                            begin
                                @sender_account.lock!

                                if @recipient.present?
                                    @recipient_account.lock!
                                    
                                    @recipient_account.update!(balance: @recipient_account.reload.balance + (@total_amount * @exchange_rate))

                                    sender_activity = @sender.activities.where(smx_transaction_id: user_transaction.id).last
                                    recepient_activity = @recipient.activities.where(smx_transaction_id: user_transaction.id).last
                                    
                                    if sender_activity.present?
                                        sender_activity.update(status: SmxTransaction.statuses[:completed_])
                                    end

                                    if recepient_activity.present?
                                        recepient_activity.update(status: SmxTransaction.statuses[:completed_])
                                    end
                                
                                    user_transaction.update(status: SmxTransaction.statuses[:completed_])
                                    puts("Done: #{user_transaction.status}")
                                    UserMailer.trans_summary(user_transaction.id).deliver_now
                                else
                                    formatted_amount = @sender.get_formatted_amount(@sent_to_recipient, user_transaction.country_to)
                                    payout_service_name = user_transaction.response_hash[:payout_service]
                                    SmsService.new({phone_number: user_transaction.recipient_telephone, first_name: @sender.first_name.capitalize, last_name: @sender.last_name.capitalize, formatted_amount: formatted_amount, payout_service_name: payout_service_name}, SmxTransaction.message_types[:smx_external_send])
                                    user_transaction.update(status: SmxTransaction.statuses[:completed_])
                                    UserMailer.trans_summary(user_transaction.id).deliver_now
                                end
                            rescue => e
                                puts("Rescue: #{e}")
                                raise ActiveRecord::Rollback
                                user_transaction.update(status: SmxTransaction.statuses[:cancelled_])
                                @sender_account.update!(balance: @sender_account.reload.balance + @total_amount)
                                user_transaction.refund_charge
                                UserMailer.trans_summary(user_transaction.id).deliver_now
                            end
                        end

                        job_id = user_transaction.job_id
                        job = Sidekiq::ScheduledSet.new.find_job([job_id])
                        if job
                            job.delete
                        end
                    end
                else
                    params = {controller: 'SegoviaResponseWorker', action: 'perform', segovia_trans_id: trans_id, data: transaction}
                    TransactionlogService.new(params, 'Segovia server returned error for response', 400).fatal
                    user_transaction.update(status: SmxTransaction.statuses[:cancelled_])
                    user_transaction.refund_charge
                    @sender_account.update!(balance: @sender_account.reload.balance + @total_amount)
                    UserMailer.trans_summary(user_transaction.id).deliver_now
                end
            end
        end
    end

end