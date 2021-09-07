class UtsWorker
    include Sidekiq::Worker
    sidekiq_options retry: true
    
    def perform(smx_transaction_id, queue_type)
        UserTransaction.transaction do
            puts("smx_transaction_id: #{smx_transaction_id}")
            user_transaction = UserTransaction.find(smx_transaction_id)
            if user_transaction.blank?
                puts("UtsWorker: perform -> (smx_transaction_id, queue_type) -> Transaction not found")
            else
                @sender = user_transaction.sender
                @recipient = user_transaction.recipient

                @sender_account = @sender.account.profile
                @recipient_account = @recipient.present? ? @recipient.account.profile : nil

                @net_amount = user_transaction.net_amount #10$
                @total_amount = @net_amount + user_transaction.fees #11$
                @sent_to_recipient = @net_amount #$10

                @exchange_rate = 1

                if queue_type == 'smx_transaction_queue'
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

                            else
                                formatted_amount = User.get_formatted_amount(@sent_to_recipient, user_transaction.country_to)
                                SmsService.new({phone_number: user_transaction.recipient_telephone, first_name: @sender.first_name.capitalize, last_name: @sender.last_name.capitalize, formatted_amount: formatted_amount}, SmxTransaction.message_types[:smx_non_smx_send_])
                                UserMailer.trans_summary(user_transaction.id).deliver_now
                            end
                        rescue => e
                            puts("Rescue: #{e}")
                            user_transaction.update(status: SmxTransaction.statuses[:cancelled_])
                            @sender_account.update!(balance: @sender_account.reload.balance + @total_amount)
                            UserMailer.trans_summary(user_transaction.id).deliver_now
                            raise ActiveRecord::Rollback
                        end
                    end
                elsif queue_type == 'international_transaction_queue'
                    params = {user_transaction_id: user_transaction, queue: queue_type}
                    iso_country = ISO3166::Country.find_country_by_name(user_transaction.country_to)
                    if iso_country.blank?
                        LogService.new(params, "Receiver currency is blank", 500).fatal
                        UserMailer.trans_error_email(params, "Receiver currency is blank").deliver_now
                        user_transaction.update(status: SmxTransaction.statuses[:cancelled_])
                        @sender_account.update!(balance: @sender_account.reload.balance + @total_amount)
                        UserMailer.trans_summary(user_transaction.id).deliver_now
                    else
                        currency_code = iso_country.currency.iso_code
                        if ['UGX', 'KES', 'GHS', 'TZS'].include?(currency_code)
                            SegoviaService.new(user_transaction.id).pay
                        else
                            LogService.new(params, "Country transfer not supported", 500).fatal
                            UserMailer.trans_error_email(params, "Country transfer not supported").deliver_now
                            user_transaction.update(status: SmxTransaction.statuses[:cancelled_])
                            @sender_account.update!(balance: @sender_account.reload.balance + @total_amount)
                            UserMailer.trans_summary(user_transaction.id).deliver_now
                        end
                    end
                else
                    # USA Queue
                end
            end
        end
    end

end