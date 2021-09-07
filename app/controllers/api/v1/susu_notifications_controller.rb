class Api::V1::SusuNotificationsController < Api::V1::BaseController
  before_action :set_susu_notification, only: [:show, :update, :destroy]

  # GET /susu_notifications
  def index
    @susu_notifications = SusuNotification.all

    render json: @susu_notifications
  end

  # GET /susu_notifications/1
  def show
    render json: @susu_notification
  end

  # POST /susu_notifications
  def create
    @susu_notification = SusuNotification.new(susu_notification_params)

    if @susu_notification.save
      render json: @susu_notification, status: :created, location: @susu_notification
    else
      render json: @susu_notification.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /susu_notifications/1
  def update
    if @susu_notification.update(susu_notification_params)
      render json: @susu_notification
    else
      render json: @susu_notification.errors, status: :unprocessable_entity
    end
  end

  # DELETE /susu_notifications/1
  def destroy
    @susu_notification.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_susu_notification
      @susu_notification = SusuNotification.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def susu_notification_params
      params.require(:susu_notification).permit(:notice_type, :transaction_id, :susu_id, :notified_by_id)
    end
end
