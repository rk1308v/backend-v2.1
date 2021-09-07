class Api::V1::SusuInvitesController < Api::V1::BaseController
  before_action :set_susu_invite, only: [:show, :update, :destroy]
  
  def_param_group :susu_invite do
    param :susu_invite, Hash, required: true, action_aware: true do
      param :accepted, [true, false], required: true, allow_nil: false
      param :sender_id, Integer, required: true, allow_nil: false
      param :recipient_id, Integer, required: true, allow_nil: false
      param :susu_id, Integer, required: true, allow_nil: false
    end
  end

  #api :GET, '/susu_invites', 'List Susu Invites'
  def index
    @susu_invites = SusuInvite.page(params[:page]).per(params[:per])

    render json: @susu_invites
  end

  #api :GET, '/susu_invites/:id', 'Show Susu Invite'
  def show
    render json: @susu_invite
  end

  #api :POST, '/susu_invites', 'Create Susu Invite'
  param_group :susu_invite
  def create
    @susu_invite = SusuInvite.new(susu_invite_params)

    if @susu_invite.save
      render json: @susu_invite, status: :created, location: @susu_invite
    else
      render json: @susu_invite.errors, status: :unprocessable_entity
    end
  end

  #api :PUT, '/susu_invites/:id', 'Update Susu Invite'
  param_group :susu_invite
  def update
    if @susu_invite.update(susu_invite_params)
      render json: @susu_invite
    else
      render json: @susu_invite.errors, status: :unprocessable_entity
    end
  end

  #api :DELETE, '/susu_invites/:id', 'Destroy Susu Invite'
  def destroy
    @susu_invite.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_susu_invite
      @susu_invite = SusuInvite.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def susu_invite_params
      params.require(:susu_invite).permit(:accepted, :sender_id, :recipient_id, :susu_id)
    end
end
