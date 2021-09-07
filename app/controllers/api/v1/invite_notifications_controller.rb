class Api::V1::InviteNotificationsController < Api::V1::BaseController
  before_action :set_invite_notification, only: [:show, :update, :destroy]

  # GET /invite_notifications
  def index
    @invite_notifications = InviteNotification.all

    render json: @invite_notifications
  end

  # GET /invite_notifications/1
  def show
    render json: @invite_notification
  end

  # POST /invite_notifications
  def create
    @invite_notification = InviteNotification.new(invite_notification_params)

    if @invite_notification.save
      render json: @invite_notification, status: :created, location: @invite_notification
    else
      render json: @invite_notification.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /invite_notifications/1
  def update
    if @invite_notification.update(invite_notification_params)
      render json: @invite_notification
    else
      render json: @invite_notification.errors, status: :unprocessable_entity
    end
  end

  # DELETE /invite_notifications/1
  def destroy
    @invite_notification.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_invite_notification
      @invite_notification = InviteNotification.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def invite_notification_params
      params.require(:invite_notification).permit(:notified_by_id)
    end
end
