class Api::V1::TransferNotificationsController < Api::V1::BaseController
  before_action :set_transfer_notification, only: [:show, :update, :destroy]

  # GET /transfer_notifications
  def index
    @transfer_notifications = TransferNotification.all

    render json: @transfer_notifications
  end

  # GET /transfer_notifications/1
  def show
    render json: @transfer_notification
  end

  # POST /transfer_notifications
  def create
    @transfer_notification = TransferNotification.new(transfer_notification_params)

    if @transfer_notification.save
      render json: @transfer_notification, status: :created, location: @transfer_notification
    else
      render json: @transfer_notification.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /transfer_notifications/1
  def update
    if @transfer_notification.update(transfer_notification_params)
      render json: @transfer_notification
    else
      render json: @transfer_notification.errors, status: :unprocessable_entity
    end
  end

  # DELETE /transfer_notifications/1
  def destroy
    @transfer_notification.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_transfer_notification
      @transfer_notification = TransferNotification.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def transfer_notification_params
      params.require(:transfer_notification).permit(:notice_type, :amount, :transaction_id, :notified_by_id)
    end
end
