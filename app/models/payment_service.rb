class PaymentService < ApplicationRecord
	has_many :user_transactions

	enum transaction_queue: {'1': 'smx_transaction_queue', '2': 'usa_transaction_queue', '3': 'international_transaction_queue'}

	def pay(user_transaction_id)
		@user_transaction = UserTransaction.find(user_transaction_id)
		if @user_transaction.blank?
			return { status: 500, error: "Something went wrong. Try again later."}
		else
			ActiveRecord::Base.transaction do
                begin
                    @sender = @user_transaction.sender
                    @sender_account = @sender.account.profile
                    @net_amount = @user_transaction.net_amount
                    @total_amount = @net_amount + @user_transaction.fees
                    @sender_account.lock!
                    @sender_account.update!(balance: @sender_account.reload.balance - @total_amount)
                    @recepient_type = @user_transaction.recipient_type

                    if self.service_name == SmxTransaction.const_names[:segovia_service_name]
                    	puts("Paying with Segovia")
	                    self.segovia_pay(@user_transaction.id, @recepient_type)
	                else
	                	puts("Paying with transferto")
	                	# Code for other queue
	                end
                    return { status: 200, message: "Your transaction is pending", summary: @user_transaction.summary(@sender), balance: @sender_account.balance}
                rescue => e
                	puts("Error: #{e}")
                    raise ActiveRecord::Rollback
                    return { status: 500, error: "Something went wrong. Try again later."}
                end
            end
		end
	end

	def segovia_pay(user_transaction_id, recepient_type)
		queue_name = PaymentService.transaction_queues["#{recepient_type}"]
		puts("queue_name: #{queue_name} : #{recepient_type}")
		UtsWorker.set(queue: queue_name).perform_in(5.seconds, user_transaction_id, queue_name)
	end
end
