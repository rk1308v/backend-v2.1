class Api::V1::DashboardsController < Api::V1::BaseController
  before_action :set_default_params , only: :notifications


  def_param_group :dashboard do
    param :dashboard, Hash, required: true, action_aware: true do
      param :offset, Integer, required: true, allow_nil: false
      param :count, Integer, required: true, allow_nil: false
    end
  end 

  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  #    Get Notifications
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  api :GET, '/notifications','List of notifications for the users'
  param_group :dashboard
  def notifications

    resp = []
    #Get the notifications than have not been queried before ("read" is still false)
    #and those that have been queried less than 2 days ago ("read" updated to true 2 days ago)
    notification_list = @user.notifications.page(params[:page]).per(params[:per])
    temp = notification_list.where("read = ? AND updated_at >= ?", true, DateTime.now - 2.day)
    temp += notification_list.where(read: false)
    notification_list = temp.uniq.sort_by(&:created_at).reverse
                                      #render json: notification_list
    #return
    #Set http return status and notifications
    #This returns entries sorted from first to last according to created_at time
    @notifications = set_status_and_list_limit notification_list

    #Sort the list from last to first according to created_at time
    #@notifications = @notifications.reverse #sort_by(&:created_at)

    if @notifications.present?
      #@notifications =  @notifications.as_json(only: [:id, :notice, :created_at])

      @notifications.each do |notification|

        notice_type = notification.noticeable[:notice_type]

        #Transfer notification type
        if notification['noticeable_type'] == 'TransferNotification'
          
          #Only marked 'read' to true to 'send_' notifications  
          if (notification[:read] == false) && (notice_type == "send_")
            notification[:read] = true
            notification.save
          end

          notif = get_transfer_notification notification
          if notif
            resp << notif
          end

        #Susu notification type - Not implemented
        elsif notification['noticeable_type'] == 'SusuNotification'
          notif = get_susu_notification notification 
          if notif
            resp << notif
          end

        #Invite notification type - Not implemented
        elsif  notification['noticeable_type'] == 'InviteNotification'
          notif = get_invite_notification notification
          if notif
            resp << notif
          end      
        end

      end
  
      if resp.present?
        render status: @status, json: { notifications: resp } 
      else
        render json: { message: "You have no notification at this moment." }
      end
    else 
      render json: { message: "You have no notification at this moment." } 
    end 
  end
 
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  #    Get Activities
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  api :GET, '/activities','List of activities for the users'
  param_group :dashboard
  def activities
    #Get activity list from the last 12 months
    activity_list =  @user.activities.page(params[:page]).per(params[:per])
      .where('created_at BETWEEN ? AND ? ', DateTime.now - 1.year, DateTime.now)

    #Set http return status and notifications
    @activities = set_status_and_list_limit activity_list

    #If activities not empty
    if @activities.present?
      @activities =  @activities.as_json(only: [:id, :activity, :amount, :status, :created_at])

      #Prepare the response
      @activities.each do |activity|

        if activity['activity'].split.first == "Sent"
          activity[:amount] = "-#{activity['amount']}"
        elsif activity['activity'].split.first == "Received"
          activity[:amount] = "+#{activity['amount']}"
        end

        activity[:date] = activity.delete "created_at"
        activity[:date] = activity[:date].to_formatted_s(:short)
        activity[:status] = SmxTransaction.status_string activity['status']

      end
      render status: status, json: { activities: @activities  }
    else 
      render json: { message: "You have no activity at this moment." } 
    end 
  end

  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  #    Update Notificatons
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  def update_notifications
    id = dashboard_params[:id]
    notice_type = dashboard_params[:notice_type]
    option = dashboard_params[:option]

    if notice_type == 'TransferNotification'
      if option == "Pay"

        notification = @user.notifications.find_by_id(id)
        noticeable = notification.noticeable

        @recipient = noticeable.notified_by
        amount = noticeable[:amount]
        trans_type = SmxTransaction.trans_types[:send_]
        description = notification[:notice].split(':')[1]#.tr("'\"", "").downcase
        #formatted_amount = @user.get_formatted_amount BigDecimal(amount)
        #description = "@#{@user.username} paid you #{formatted_amount} for your request: #{description}"
        description = "Your request #{description}"
      
        @transaction = UserTransactionService.new(@user, @recipient, amount, trans_type, description)
        resp = @transaction.send_money

        ## Something went really wrong. Should never happen.
        if resp.nil?
          render status: 500, json: {error: "Oops! Something went wrong. Try again later"}
        end
        notification[:read] = true
        notification.save
        if !resp.try(:first)[:error].present?
          render status: 412, json: resp.first
        else
          render json: resp.try(:first)
        end

      elsif option == "Decline"
        notification = @user.notifications.find_by_id(id)
        notification[:read] = true
        notification.save
      end
    end
  end

  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  #    Get balance
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  api :GET, '/balance','List of balance for the users'
  def balance 
    #@balance = @user.user_account.balance
    @balance = @user.get_formatted_balance
    render json: { balance: @balance }
  end

  private

    def set_status_and_list_limit list
      if list.count > params[:offset].to_i + params[:count].to_i
        @status = 206
      else
        @status = 200
      end

      list.drop(params[:offset].to_i).first(params[:count].to_i)
    end

    def get_transfer_notification notification

      options = []
      notice_type = notification.noticeable.notice_type
      if notice_type == "request_"
        options << "Pay"
        options << "Decline"

        { id: notification[:id],
          notice: notification[:notice],
          date: notification[:created_at].to_formatted_s(:short),
          notice_type: notification[:noticeable_type],#"User",
          options: options
        }

      elsif notice_type == "send_"
                  
        { id: notification[:id],
          notice: notification[:notice],
          date: notification[:created_at].to_formatted_s(:short),
          notice_type: notification[:noticeable_type]#"User"
        }

      end
    end
    
    def get_susu_notification notification
      #trans_type = SmxTransaction.find_by_id(notification.noticeable.smx_transaction_id).transactionable.trans_type

    end

    def get_invite_notification notification

    end

    def set_default_params
      #params[:page] = params[:page].present? ? params[:page] : 1
      #params[:per] = params[:per].present? ? params[:per] : 100
    end

    # Only allow a trusted parameter "white list" through.
    def dashboard_params
      params.require(:dashboard).permit(:id, :notice, :notice_type, :option)
    end
end
