class Api::V1::NotificationsController < Api::V1::BaseController
    before_action :set_notification, only: [:show, :update, :destroy]

    def_param_group :notification1 do
        param :notification1, Hash, required: true, action_aware: true do
            param :offset, Integer, required: true, allow_nil: false
            param :count, Integer, required: true, allow_nil: false
        end
    end 

    def_param_group :notification2 do
        param :notification2, Hash, required: true, action_aware: true do
            param :id, Integer, required: true, allow_nil: false
            param :notice, String, required: true, allow_nil: false
            param :notice_type, String, required: true, allow_nil: false
            param :option, String, required: true, allow_nil: false
        end
    end 

    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    #    Get Notifications
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    api :GET, '/notifications','List of notifications for the users'
    param_group :notification1
    def index
        resp = []
        #Get the notifications than have not been queried before ("read" is still false)
        #and those that have been queried less than 2 days ago ("read" updated to true 2 days ago)
        notification_list = @user.notifications#.page(params[:page]).per(params[:per])
        # temp = notification_list.where("read = ? AND updated_at >= ?", true, DateTime.now - 2.day)
        # temp += notification_list.where(read: false)
        notifications = notification_list.where("read = ? AND created_at >= ?", false, DateTime.now - 30.day)
        notifications = notifications.uniq.sort_by(&:created_at).reverse
        #Set http return status and notifications
        #This returns entries sorted from first to last according to created_at time
        if @user.email_verified == false
            resp = [{ 
                        id: 0,
                        notice: "Your email account is not verified. Please verify your email",
                        date: DateTime.now.to_formatted_s(:short),
                        notice_type: "account_status_"
                    }]
            render status: 200, json: {status: 200, notifications: resp, total_count: 1 } 
        else
            @notifications = set_status_and_list_limit notifications
            if @notifications.present?
                #@notifications =  @notifications.as_json(only: [:id, :notice, :created_at])
                @notifications.each do |notification|
                    #Transfer notification type
                    if notification['noticeable_type'] == 'TransferNotification'
                    #Only marked 'read' to true to 'send_' notifications  
                        if (notification[:read] == false) && (notification.noticeable[:notice_type] == "send_")
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
                    render status: @status, json: { notifications: resp, total_count: notifications.count } 
                else
                    render json: { message: "You have no notification at this moment.", total_count: notifications.count }
                end
            else 
                render json: { message: "You have no notification at this moment.", total_count: notifications.count } 
            end 
        end
        
    end


    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    #    Update Notificatons
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    api :PUT, '/notifications/update_notification','Update user notification'
    param_group :notification2
    def update_notification
        id = notification_params[:id]
        notice_type = notification_params[:notice_type]
        option = notification_params[:option]
        notification = @user.notifications.find_by_id(id)
        if notification
            if notice_type == 'request_'
                if option == "Pay"
                    notification[:read] = true
                    notification.save 
                    puts "Notification marked read without being paid."
                    render status: 200, json: {message: "Request declined!"}
                elsif option == "Decline"
                    notification[:read] = true
                    notification.save
                    puts  "Request declined!"
                    render status: 200, json: {message: "Request declined!"}
                end
            end
        else
            puts "Notification does not exists."
            render status: 500, json: {error: "Oops! Something went wrong. Try again later"}
        end
    end

    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    #    Get Notificatons Count
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    api :GET, '/notifications_count','Total count of unread notifications for the last 30 days'
    def notifications_count
        count = @user.notifications.where("read = ? AND created_at >= ?", false, DateTime.now - 30.day).uniq.count 
        render status: 200, json: { status: 200, count: count } 
    end
    
    # # GET /notifications/1
    # def show
    #   render json: @notification
    # end

    # # POST /notifications
    # def create
    #   @notification = Notification.new(notification_params)

    #   if @notification.save
    #     render json: @notification, status: :created, location: @notification
    #   else
    #     render json: @notification.errors, status: :unprocessable_entity
    #   end
    # end

    # # PATCH/PUT /notifications/1
    # def update
    #   if @notification.update(notification_params)
    #     render json: @notification
    #   else
    #     render json: @notification.errors, status: :unprocessable_entity
    #   end
    # end

    # # DELETE /notifications/1
    # def destroy
    #   @notification.destroy
    # end

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
            { 
                id: notification[:id],
                notice: notification[:notice],
                date: notification[:created_at].to_formatted_s(:short),
                notice_type: notice_type,
                amount: @user.get_formatted_amount_display(notification.noticeable.amount),
                recipient_id: notification.noticeable.notified_by.id,
                recipient_first_name: notification.noticeable.notified_by.first_name,
                recipient_last_name: notification.noticeable.notified_by.last_name, 
                recipient_username: notification.noticeable.notified_by.username,
                notification_date: notification.created_at,
                picture: notification.noticeable.notified_by.present? ? notification.noticeable.notified_by.picture.avatar.url(:thumb) : '',
                options: options
            }
        elsif notice_type == "send_"          
            { 
                id: notification[:id],
                notice: notification[:notice],
                date: notification[:created_at].to_formatted_s(:short),
                notification_date: notification.created_at,
                notice_type: notice_type
            }
        end
    end
    
    def get_susu_notification notification
        #trans_type = SmxTransaction.find_by_id(notification.noticeable.smx_transaction_id).transactionable.trans_type
    end

    def get_invite_notification notification

    end

    # Use callbacks to share common setup or constraints between actions.
    def set_notification
        @notification = Notification.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def notification_params
        params.require(:notification).permit(:id, :notice, :notice_type, :option)
    end
end
