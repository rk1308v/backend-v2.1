class PaymentProcessorService
	
	attr_accessor :params, :payment_type, :total_amount

	def initialize params, payment_type
		self.params = params
		self.payment_type = payment_type
		self.total_amount = params.has_key?(:total_amount) ? BigDecimal(params[:total_amount].to_s) : BigDecimal("0.0")
	end

	def process_payment
		case payment_type
			when SmxTransaction.payment_types[:smx_account_]
				return smx_payment
			when SmxTransaction.payment_types[:card_]
				return card_or_bank_payment
			when SmxTransaction.payment_types[:bank_]
				return card_or_bank_payment
			else
				return {status: 500, message: 'Something went wrong. Try again later.'}
		end
	end

	def smx_payment
		begin
        	user_account.lock!
			user_account.update!(balance: user_account.reload.balance - total_amount)
			recepient_account.lock!
			recipient_balance = recepient_account.reload.balance.to_f
			new_balance = recipient_balance + total_amount
			if recepient_account.update(balance: new_balance)
				user_transaction.update(status: SmxTransaction.statuses[:completed_])
				puts 'Here 1'
				return { 
							status: 200, 
							message: "Your transaction is completed", 
							summary: user_transaction.summary(user), 
							balance: user_account.balance
						}
			else
				puts 'Here 2'
				return { status: 500, error: "Something went wrong. Try again later."}
			end
        rescue => e
        	puts("Error: #{e}")
            raise ActiveRecord::Rollback
            user_transaction.update(status: SmxTransaction.statuses[:cancelled_])
            user_account.update!(balance: user_account.reload.balance + total_amount)
            UserMailer.trans_summary(user_transaction.id).deliver_now
            puts 'Here 3'
            return { status: 500, error: "Something went wrong. Try again later."}
        end
	end

	def card_or_bank_payment
		puts "Heerere: #{ENV['PAYMENT_PROCESSOR']}"
		if PaymentProcessor.live.last.name == SmxTransaction.payment_processors[:stripe_]
			begin
	            @charge = Stripe::Charge.create({
	                customer: params[:customer],
	                amount: params[:amount],
	                source: params[:source],
	                currency: params[:currency]
	            })
	            puts @charge
	            return @charge
	        rescue => e
	        	puts("Error: #{e}")
	            return nil
	        end
	    else
	    	return nil
	    end
	end

	private

	def user_transaction
		return UserTransaction.find params[:user_transaction_id]
	end

	def user
		return User.find params[:user_id]
	end

	def user_account
		return user.account.profile
	end

	def recepient
		return User.find params[:recipient_id]
	end

	def recepient_account
		return recepient.account.profile
	end

end