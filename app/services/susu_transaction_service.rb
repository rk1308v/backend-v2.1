class SusuTransactionService
  def  initialize(user,susu_id,amount,description)
    @user = user
    @susu_id = susu_id 
    @amount =  BigDecimal(amount)
    @description = description
    @message = []
    @susu_countries = ["usa", "bfa"]
    check_service_availability
    check_user_profile_verified
    check_account
    check_user_account
    find_susu
    check_user_membership
    check_current_round 
  end

  def initialize(user)
    @user = user
  end

  def pay_in 
    if @message.count == 0
      ActiveRecord::Base.transaction do
        begin
          @user_account.lock!
          @user_account.update!(balance: @user_account.reload.balance - BigDecimal(@amount))
          @susu_membership.lock!
          payout_round = @susu_membership.reload.last_payin_round + 1
          @susu_membership.update(last_payin_round: payout_round)
          cteate_transaction
          cteate_smx_transaction
          create_susu_notification
          create_susu_activity
          @message << "Susu transaction successfull"
        rescue ActiveRecord::Rollback 
          @message[@message.index("Susu transaction successfull")] = "Rolled Back"
        end
      end
    else 
      @message
    end
  end

  private

  def check_service_availability
    unless @susu_countries.include? @user.country.downcase
      @message << "This service is not currently available in your country"
    end
  end

  def check_user_profile_verified
    @message << "You need to verify your phone number to make this transaction" if !@user.phone_verified
    @message << "You need to verify your email address to make this transaction" if !@user.email_verified
  end

  def check_account
    if @message.count == 0
      @account = @user.try(:account)
      @message << "Can not intiate the transfer.Account not found" if !@account.present?
    end
  end

  def check_user_account
    if @message.count == 0
      @user_account = @user.try(:account).try(:profile)
      @message << "User account not found" if !@user_account.present?
    end
  end

  def check_balance 
    if @message.count == 0
      @message << "You dont have enough money for this transaction. Please add money and try again"  if ((@user_account.reload.balance - BigDecimal(@amount)) <= 0.0)
    end
  end


  def find_susu
    if @message.count == 0
      @susu = Susu.find_by_id(@susu_id)
      @message << "Susu Not found" if !@susu.present?
    end
  end

  def check_user_membership
    if @message.count == 0
      @susu_membership = @susu.susu_memberships.where(user_id: @user.id).first
      @message << "Not susu group member" if !@susu_membership.present?
    end
  end

  def check_current_round 
    if @message.count == 0 
      @message << "Current round is less than the last paying round" if  @susu.current_round <= @susu_membership.last_payin_round 
    end
  end

  def cteate_transaction
    if @message.count == 0
      ActiveRecord::Base.transaction do
        begin
          @susu_transaction = SusuTransaction.create(net_amount: @amount,fees: 0,round: @susu.rounds_count,trans_type: "User",payment_type: "Susu" ,status: "complete",susu_id: @susu.id,user_id: @user.id,description: @description)
        rescue ActiveRecord::Rollback 
          @message << "Rolled back transactions"
        end
      end
    end
  end

  def cteate_smx_transaction
    if @message.count == 0
      ActiveRecord::Base.transaction do
        begin
          #create it through the polymorphic
          #@susu_transaction = SmxTransaction.create(amount: @amount, transitionable: @susu_transaction)
        rescue ActiveRecord::Rollback 
          @message << "Rolled back smx"
        end
      end
    end
  end



  def create_susu_notification
    if @message.count == 0
      ActiveRecord::Base.transaction do
        begin
          @susu.susu_memberships.each do |susu_member|
            susu_member.user.notifications.create! read: false,noticeable: @susu_transaction,notice: "#{@user.username} sent #{BigDecimal(@amount)} to susu group #{@susu.name} "
          end
        rescue ActiveRecord::Rollback 
          @message << "Rolled back susu notification"
        end
      end
    end
  end

  def create_susu_activity
    if @message.count == 0
      ActiveRecord::Base.transaction do
        begin
          @user.activities.create! activity: "Sent to susu group #{@susu.name}",amount: "#{BigDecimal(@amount)}"
        rescue ActiveRecord::Rollback 
          @message << "Rolled back susu notification"
        end
      end
    end
  end
end

