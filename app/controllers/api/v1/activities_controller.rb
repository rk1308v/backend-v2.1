class Api::V1::ActivitiesController < Api::V1::BaseController
    before_action :set_activity, only: [:show, :update, :destroy]

    def_param_group :activity do
        param :activity, Hash, required: true, action_aware: true do
            param :offset, Integer, required: true, allow_nil: false
            param :count, Integer, required: true, allow_nil: false
        end
    end

    # Get users Transactions
    def users_transactions
        if @user.role == 'admin_' && @api_key == ENV['ADMIN_API_KEY']
            trans_list =  UserTransaction.where(trans_type: :sent_).where('created_at BETWEEN ? AND ? ', DateTime.now - 1.year, DateTime.now)
            transactions = set_status_and_list_limit trans_list
            transaction_data = Array.new

            if transactions.present?
                transactions.each do |user_transaction|
                    receiver_id = user_transaction.recipient.present? ? user_transaction.recipient_id : 0
                    receiver_name = user_transaction.recipient.present? ? user_transaction.recipient.full_name : (user_transaction.response_hash[:recipient_name].present? ? user_transaction.response_hash[:recipient_name] : '')
                    receiver_telephone = user_transaction.recipient.present? ? user_transaction.recipient.telephone : user_transaction.response_hash[:recipient_telephone]
                    amount = user_transaction.net_amount.strip
                    sender_country = user_transaction.sender.country
                    transaction_data << {
                        id: user_transaction.id,
                        date: user_transaction.formatted_time,
                        amount: User.get_formatted_amount(amount, sender_country),
                        status: user_transaction.transaction_status,
                        sender_name: user_transaction.sender.full_name,
                        sender_id: user_transaction.sender_id,
                        receiver_name: receiver_name ,
                        receiver_id: receiver_id,
                        receiver_telephone: PhonerService.new(receiver_telephone).format_number,                      
                        description: user_transaction.description.blank? ? '' : user_transaction.description
                    }
                end
            end
            render status: @status, json: {status: @status, transactions: transaction_data, total_count: trans_list.count}
        else
            render status: 400, json: {status: 400, error: "Invalid request"}
        end 
    end

    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    #    Get Activities
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    api :GET, '/activities','List of user activities'
    param_group :activity
    def index
        #Get activity list from the last 12 months
        activity_list =  @user.activities.where('created_at BETWEEN ? AND ? ', DateTime.now - 1.year, DateTime.now)
        @activities = set_status_and_list_limit activity_list
        activity_data = Array.new

        if @activities.present?
            @activities.each do |activity|
                if UserTransaction.exists?(activity['smx_transaction_id'].to_i)
                    user_transaction = UserTransaction.find(activity['smx_transaction_id'].to_i)
                    activity_status = user_transaction.transaction_status
                    return_status = activity_status
                    if user_transaction.status == SmxTransaction.statuses[:completed_] && user_transaction.sender_id == @user.id
                        return_status = 'Sent'
                    elsif user_transaction.status == SmxTransaction.statuses[:completed_] && user_transaction.recipient_id == @user.id
                        return_status = 'Received'
                    end
                    
                    recepient_phone = user_transaction.recipient.present? ? user_transaction.recipient.telephone : user_transaction.response_hash[:recipient_telephone]
                    activity_data << {
                        id: activity.id,
                        activity: activity.activity,
                        username: activity.is_sent == true ? (user_transaction.recipient.present? ? user_transaction.recipient.username : '') : user_transaction.sender.username,
                        formated_amount: user_transaction.response_hash[:amount].strip,
                        amount: @user.get_formatted_amount_display(user_transaction.net_amount),
                        user_id: user_transaction.sender_id,
                        updated_at: activity.updated_at,
                        status: return_status,
                        smx_transaction_id: activity.smx_transaction_id,
                        date: user_transaction.formatted_time,
                        receiver_name: activity.is_sent == true ? (user_transaction.recipient.present? ? user_transaction.recipient.full_name : (user_transaction.response_hash[:recipient_name].present? ? user_transaction.response_hash[:recipient_name] : (user_transaction.recipient_telephone.present? ? user_transaction.recipient_telephone : ''))) : user_transaction.sender.full_name,
                        sender_name: user_transaction.sender.full_name,
                        receiver_pic: activity.is_sent == true ? (user_transaction.recipient.present? ? user_transaction.recipient.picture.avatar.url(:thumb) : (user_transaction.response_hash[:recipient_name].present? ? receiver_pic(user_transaction.response_hash[:recipient_name]) : '')) : (user_transaction.sender.picture.avatar.url(:thumb)),
                        description: user_transaction.description.blank? ? '' : user_transaction.description,
                        recipient_id: activity.is_sent == true ? (user_transaction.recipient.present? ? user_transaction.recipient_id : 0) : user_transaction.sender_id,
                        recipient_telephone: PhonerService.new(recepient_phone).format_number,
                        sent_received: activity.is_sent == true ? 1 : 0
                    }
                end
            end
        end 
        if activity_data.count > 0
            render status: @status, json: {status: @status, activities: activity_data, total_count: activity_list.count }
        else
            render status: @status, json: {status: @status, message: "You have no activity at this moment.", activities: [], total_count: activity_list.count } 
        end
    end

    def receiver_pic receiver_name
        return "#{ENV['LETTER_IMAGES']}/#{receiver_name.first.upcase}_thumb.png"
    end
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    #    Get Friends Activities
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    api :GET, '/friend_activities','List of friend activities'
    param_group :activity
    def friend_activities
        resp = []
        transactions = []
        recepient_id = params[:friend_id]
        telephone_number = params[:telephone]
        @formatted_number = ''
        if telephone_number.present?
            telephone_number = telephone_number.gsub(/[^0-9A-Za-z]/, '')
            pn = Phoner::Phone.parse("+#{telephone_number}")
            if pn
                @formatted_number = pn.format("(+%c) %a-%f-%l")
            end
        end

        if params.has_key?(:friend_id)
            transactions = @user.sender_transactions.where(recipient_id: recepient_id).where('created_at BETWEEN ? AND ? ', DateTime.now - 1.year, DateTime.now)
            transactions = transactions + UserTransaction.where('sender_id = ? AND recipient_id = ?', recepient_id, @user.id)
        else
            transactions = @user.sender_transactions.where(recipient_telephone: @formatted_number).where('created_at BETWEEN ? AND ? ', DateTime.now - 1.year, DateTime.now)
        end

        @activities = set_status_and_list_limit transactions

        if @activities.present?
            @activities.each do |activity|
                if activity.present?
                    transaction_type = activity.sender_id == @user.id ? 0 : 1
                    activity_status = activity.response_hash[:transaction_status]
                    return_status = activity_status
                    if ['Sent', 'Received'].include?(activity_status)
                        return_status = transaction_type == 0 ? 'Sent' : 'Received'
                    end

                    id = activity[:id]
                    date = activity.created_at
                    status = return_status
                    amount =  @user.get_formatted_amount(activity.net_amount, @user.country)
                    description = activity.description.present? ? activity.description.capitalize : ''
                    sender_name = activity.sender.full_name
                    receiver_name = activity.recipient.present? ? activity.recipient.full_name : (activity.response_hash[:recipient_name].present? ? activity.response_hash[:recipient_name] : (activity.recipient_telephone.present? ? activity.recipient_telephone : ''))
                    
                    temp = {id: id, activity: transaction_type == 0 ? 'Sent' : 'Received', amount: amount, amount_with_currency: @user.get_formatted_amount_display(activity.net_amount), status: status, date: date, description: description, sender_name: sender_name, receiver_name: receiver_name, transaction_type: transaction_type}
                    resp << temp
                end
            end

            sent_transactions = []
            received_transactions = []

            sent_transactions = params.has_key?(:friend_id) ? UserTransaction.where('sender_id = ? AND recipient_id = ?', @user.id, recepient_id) : UserTransaction.where('sender_id = ? AND recipient_telephone = ?', @user.id, @formatted_number)
            
            received_transactions = params.has_key?(:friend_id) ? UserTransaction.where('sender_id = ? AND recipient_id = ?', recepient_id, @user.id) : []
            
            sent_amount = sent_transactions.map(&:net_amount).inject(0, &:+)
            received_amount = received_transactions.map(&:net_amount).inject(0, &:+)
            trans_count = sent_transactions.count + received_transactions.count

            render status: @status, json: {status: @status, activities: resp, summary: {sent: @user.get_formatted_amount_display(sent_amount), received: @user.get_formatted_amount_display(received_amount), transaction_count: trans_count, total_count: transactions.count}}
        else 
            render status: @status, json: {status: @status, message: "You have no activity at this moment." } 
        end
    end

    private

    def set_status_and_list_limit list
        list = list.sort_by(&:created_at).reverse
        if list.count > params[:offset].to_i + params[:count].to_i
            @status = 206
        else
            @status = 200
        end
        list.drop(params[:offset].to_i).first(params[:count].to_i)
    end
end
