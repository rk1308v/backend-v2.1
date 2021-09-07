class Api::V1::SususController < Api::V1::BaseController
  before_action :set_susu, only: [:show, :update, :destroy]

  def_param_group :susu do
    param :susu, Hash, required: true, action_aware: true do
      param :name, String, required: true, allow_nil: false
      param :days_per_round, Integer, required: true, allow_nil: false
      param :payin_amount, /\A(\d+[\.,]?\d*|\d*[\.,]?\d+)\Z/, required: true, allow_nil: false
      param :started_at, DateTime, required: true, allow_nil: false
      param :invited_users_ids, Hash, required: true, allow_nil: false
      param :description, String, required: true, allow_nil: false
    end
  end

  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  #    Create Susu
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  api :POST, '/create_susu', 'Create Susu'
  param_group :susu
  def create_susu
    #Check if user is allow to create Susu.
    message = @user.user_validity_check
    if !message 
      render status: 422, json: {error: "#{message} to create Susu" }
      return
    end

    #Check if Susu count limit is reached
    message = Susu.susu_limit_check @user
    if !message 
      render status: 422, json: {error: message }
      return
    end

    #Create Susu
    is_admin = true
    days_per_round = 7
    invited_users = params[:susu][:invited_users_ids].uniq
    date_started_midnight = params[:susu][:started_at].strip[0...10] + " 00:00" # No matter what time the user put in, round starts at midnight
    participants_count = invited_users.count + 1 # +1 to account for susu admin
    payout_amount = susu_params[:payin_amount].to_f * participants_count
    started_at = DateTime.parse(date_started_midnight) 
    ended_at = started_at + (days_per_round * participants_count).days
    @susu = Susu.new name: susu_params[:name].capitalize,
                     members_count: 1, # Only account for admin
                     rounds_count: 1,
                     # current_round: 0,   # Provided by default
                     days_per_round: days_per_round,
                     payin_amount: susu_params[:payin_amount],
                     payout_amount: susu_params[:payin_amount],
                     fees: get_fees,
                     started_at: started_at,
                     ended_at: started_at + days_per_round.days,
                     status: Susu.statuses[:created_], 
                     description: susu_params[:description]
    if @susu.save
      #Create admin membership
      message = @susu.create_membership @user, is_admin
      if message 
        render status: 422, json: {error: message }
        return
      end

      #Create user invites
      @susu.create_invitation @user, invited_users

      #Format Susu with details to return
      susu_json = get_susu_details 

      render json: susu_json 
      return 
    else
      render status: 500, json: {error: "Ooops! Something went wrong. Please try again later" }
    
    end 
  end

  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  #    Send Susu invite
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  api :POST, '/send_susu_invite', 'Create Susu invite' 
  param_group :susu
  def send_susu_invite
    @susu = Susu.find_by_id(send_invite_params[:susu_id])
    invited_users = params[:susu][:invited_users_ids].uniq
      
    #Create Invites and notifications
    if @susu
      @susu.create_invitation @user, invited_users
      render json: {message: "Invitation sent" } 
    else
      render status: 404, json: {Error: "Susu does not exist" }
    end
  end

  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  #    Get Susu Details
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  api :GET, '/susu_details:id', 'Susu Details' 
  def susu_details
    render json: get_susu_details
  end 

  
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  #    Update Susu notification
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  api :POST, '/update_susu_notification', 'Update Susu Notification' 
  def update_susu_notification
    notification = Notification.find_by_id(update_susu_invite_params[:notice_id])
    susu_notification = notification.noticeable
    notice_type = susu_notification.notice_type
    susu = susu_notification.susu
    notice_types = SusuNotification.notice_types    
    invited = notice_types[:invited_]
    joinded = notice_types[:joined_]
    due_date = notice_types[:due_date_]
    payout = notice_types[:payout_]
    late = notice_types[:late_]
    late_fee = notice_types[:late_fee_]

    if notice_type == notice_types.key(invited)
      susu_invites = susu.susu_invites.where(recipient_id: @user.id, accepted: false)
      accepted = eval(update_susu_invite_params[:accepted])

      #Invite accepted
      if  accepted == true
        if Time.now > susu.started_at

          #Create membership
          message = susu.create_membership @user, false
          if message 
            render status: 422, json: {error: message }
            return
          end

          #Update invites
          susu_invites.each do | invite |
            susu_invites[:accepted] = true
            susu_invites.save
          end

        #Invite declined
        else 
          render status: 422, json: {message: "Expired Invite" }
          return
          #message = "{message: 'Expired Invite' }"
        end
      end

    #elsif notice_type == notice_types.key(joined) #Nothing to be done
      
    elsif notice_type == notice_types.key(due_date)
      #smx_trans = notification.noticeable.smx_transaction

    #elsif notice_type == notice_types.key(payout) #Nothing to be done
      

    elsif notice_type == notice_types.key(late)
      #smx_trans = notification.noticeable.smx_transaction

    #elsif notice_type == notice_types.key(late_fee) #Nothing to be done
      #smx_trans = notification.noticeable.smx_transaction

    end

    # Update notification
    notification[:read] = true
    notification.save
    
    unless message
      render json: {message: "You have been added to Susu '#{susu.name.capitalize}'"}
    end

  end

  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  #    Make susu payin
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  api :POST, '/susus/pay_in', 'Susu Payin'
  def susu_pay_in
    #susus = @user.susus.where(status: Susu.statuses[:created_])
    susus = @user.susus.where("status = ? or status = ?", Susu.statuses[:created_], Susu.statuses[:ongoing_])

    render json: susus
    return
    
    render json: user.as_json({
        success: true,
        #avatar: picture.avatar.url(:square),
        only: [:id, :last_name, :first_name, :username]      
      })

    render json: susus
    return
    @susu_transaction = SusuTransactionService.new(@user,params[:susu_id],params[:amount],params[:description])
    render json: {status: 200,message: @susu_transaction.pay_in }
  end

  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  #    Get Susu list
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  api :GET, '/susus/susu_list', 'Susu List'
  def susu_list
    susus = @user.susus.where(status: Susu.statuses[:created_]).order("started_at desc")
    susu_arrays = []
    
    susus.each do |susu|
      susu_array <<  susus.first.as_json({
        only: [:id, :name, :payout_amount, :started_at, :ended_at]
      })
    end
    
    render json: susus_array
    return
    susu_array = []
    #susus.each do |susu|
    susu =  susus.first.as_json({
         only: [:id, :name, :payout_amount, :started_at, :ended_at],
         methods: [:susu_memberships, :susu_invites, :susu_transactions]})
    #end
    render json: susu
    #return
  end

  # api :GET, '/susus/susu_details', 'Susu details'
  # def susu_details
  #   susus = @user.susus.where(status: Susu.statuses[:created_]).order("started_at desc")
  #   susu_array = []
  #   susus.each do |susu|
  #     susu.as_json({
  #        only: [:id, 
  #               :name, 
  #               :payin_amount, 
  #               :payout_amount, 
  #               :status, 
  #               :members_count, 
  #               :started_at, 
  #               :ended_at],
  #        methods: [:susu_memberships, :susu_invites]
  #      }), status: :created
  #   end
  #   render json: susus
  #   return
  # end


  # api :GET, '/susus', 'List Susus'
  # def index
  #   @susus = Susu.page(params[:page]).per(params[:per])

  #   render json: @susus
  # end

  # api :GET, '/susus/:id', 'Show Susu'
  # def show
  #   render json: @susu
  # end

  # api :POST, '/susus', 'Create Susu'
  # param_group :susu
  # def create
  #   @susu = Susu.new(susu_params)

  #   if @susu.save
  #     render json: @susu, status: :created, location: @susu
  #   else
  #     render json: @susu.errors, status: :unprocessable_entity
  #   end
  # end

  # api :POST, '/susus', 'Create Susu'
  # param_group :susu
  # def create
  #   @susu = Susu.new(susu_params)
  #   if @susu.save
  #     render json: @susu.as_json({
  #       success: true,
  #       only: [:id, :name, :payin_amount, :payout_amount, :status, :started_at, :ended_at],
  #       methods: [:susu_memberships, :susu_invites]
  #     }), status: :created
  #   else
  #     render json: @susu.errors.full_messages.join(", "), status: :unprocessable_entity
  #   end
  # end

   
  # api :PUT, '/susus/:id', 'Update Susu'
  # param_group :susu
  # def update
  #   if @susu.update(susu_params)
  #     render json: @susu
  #   else
  #     render json: @susu.errors, status: :unprocessable_entity
  #   end
  # end

  # api :PUT, '/susus/desc:id', 'Update Susu Description'
  # param_group :susu
  # def update_desc
  #   if change_description?
  #     render json: @susu
  #   else
  #     render json: @susu.errors, status: :unprocessable_entity
  #   end
  # end

  # api :DELETE, '/susus/:id', 'Destroy Susu'
  # def destroy
  #   @susu.destroy
  # end

  # def send_susu_invite
  #   #Find Susu
  #   @susu = Susu.find_by_id(send_invite_params[:susu_id])
    
  #   #Find reciepient 
  #   @recipient = User.find_by_email send_invite_params[:reciever_email]

  #   #check for susu invite 
  #   @susu_invite = @susu.susu_invites.where(susu_id: @susu.id,sender_id: @user.id,recipient_id: @recipient.id)

  #   if @susu_invite.present? 
  #     #check for user invite then send
  #     if !@susu_invite.first.accepted
  #       render json: {status: 200, message: "Invitation Pending" } 
  #     else 
  #       render json: {status: 200, message: "Invite is already accepted by user" } 
  #     end
  #   else 
  #     #susu create 
  #     @susu_invite =  @susu.susu_invites.new(accepted: false ,susu_id: @susu.id,sender_id: @user.id,recipient_id: @recipient.id)
  #     if @susu_invite.save
  #       @recipient.notifications.create read: false , notice: "#{@user.first_name} sent you invitation for joining susu group #{@susu.name}"
  #       render json: {status: 200, message:  "invite creted" }
  #     else 
  #       render json: {status: 200, message: @susu_invite.errors.message }
  #     end

  #   end
  # end

  # api :POST, '/susus/update_invite', 'Usend_susu_invite'
  # def update_invite 
  #   @susu_invite = SusuInvite.where(id: update_invite_params[:invite_id]).first
  #   @susu = @susu_invite.susu

  #   if Time.now > @susu.started_at

  #     payout_round = SusuMembership.where(susu_id: @susu.id,user_id: @user.id).count
  #     @susu_membership = SusuMembership.new admin: false ,collected: false ,last_payin: 0,payout_round: payout_round,susu_id: @susu.id,user_id: @user.id

  #     if @susu_membership.save 
  #       @susu.susu_memberships.each do |susu_membership|
  #         susu_membership.user.notifications.create read: false , notice: "#{@user.first_name} accepted the invitaton for susu group #{@susu.name}"
  #       end
  #       @susu.update_attribute('status',"ended")
  #       render json: {status: 200,message: "Membership added to susu" }
  #     else 
  #       render json: {status: 200,message: @susu_membership.errors.message }
  #     end
  #   else 
  #     render json: {status: 200,message: "Expired Invite" }
  #   end

  # end

  private

    # Get susu details
    def get_susu_details
      if !@susu.present?
        @susu = Susu.find_by_id(params[:id]) 
      end 

      susu_json =  @susu.as_json( 
        { only: [:id, :name, :started_at, :payout_amount],
          #methods: [:users],
          include: { susu_memberships: 
            { only: [:admin, :collected, :payout_round], 
              include: { user: 
                { only:[:id, :first_name, :last_name, :username],   
                  include: { picture: 
                    { only: [:updated_at], 
                      methods:[:avatar_url]    
                    }
                  }
                }
              } 
            }
          }     
        }
      )

      susu_hash = Hash.new
      susu_hash[:id] = susu_json['id']
      susu_hash[:started_at] = susu_json['started_at']
      susu_hash[:payout_amount] = susu_json['payout_amount']      

      susu_memberships = susu_json['susu_memberships']
      users = []
      susu_memberships.each_with_index do |membership, index|
        temp = Hash.new
        temp[:admin] = membership['admin']
        temp[:collected] = membership['collected']
        temp[:payout_round] = membership['payout_round']
        temp[:id] = membership['user']['id']
        temp[:first_name] = membership['user']['first_name']
        temp[:last_name] = membership['user']['last_name']
        temp[:username] = membership['user']['username']
        temp[:avatar_updated_at] = membership['user']['picture']['updated_at']
        temp[:avatar_url] = membership['user']['picture']['avatar_url']
        users << temp
      end
      susu_hash[:users] = users 
      susu_hash
    end

    # Use callbacks to share common setup or constraints between actions.
    def get_fees
     0
    end 

    def change_description
       @susu= Susu.find(params[:id])
       @susu.descriptions << params[:description]
       @susu.save!
    end

    def set_susu
      @susu = Susu.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def susu_params
      #params.require(:susu).permit(:name, :members_count, :rounds_count, :current_round, :days_per_round, :payin_amount, :payout_amount, :fees, :started_at, :ended_at, :status, :description)
      params.require(:susu).permit(:name, 
                                   :days_per_round, 
                                   :payin_amount, 
                                   :started_at, 
                                   :susu_id, 
                                   {:invited_users_ids => []}, :description)
    end

    def send_invite_params
    params.require(:susu).permit(:susu_id, {:invited_users_ids => []})
  end

  def update_susu_invite_params
    params.require(:susu).permit(:notice_id, :notice_type, :accepted)
  end

end
