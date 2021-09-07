class Api::V1::SusuMembershipsController < Api::V1::BaseController
  before_action :set_susu_membership, only: [:show, :update, :destroy]

  def_param_group :susu_membership do
    param :susu_membership, Hash, required: true, action_aware: true do
      param :admin, [true, false], required: true, allow_nil: false
      param :collected, [true, false], required: true, allow_nil: false
      param :last_payin_round, Integer, required: true, allow_nil: false
      param :payout_round, Integer, required: true, allow_nil: false
      param :user_id, Integer, required: true, allow_nil: false
      param :susu_id, Integer, required: true, allow_nil: false
    end
  end

  #api :GET, '/susu_memberships', 'List Susu Memberships'
  def index
    @susu_memberships = SusuMembership.page(params[:page]).per(params[:per])

    render json: @susu_memberships
  end

  #api :GET, '/susu_memberships/:id', 'Show Susu Membership'
  def show
    render json: @susu_membership
  end

  #api :POST, '/susu_memberships', 'Create Susu Membership'
  param_group :susu_membership
  def create
    @susu_membership = SusuMembership.new(susu_membership_params)

    if @susu_membership.save
      render json: @susu_membership, status: :created, location: @susu_membership
    else
      render json: @susu_membership.errors, status: :unprocessable_entity
    end
  end

  #api :PUT, '/susu_memberships/:id', 'Update Susu Membership'
  param_group :susu_membership
  def update
    if @susu_membership.update(susu_membership_params)
      render json: @susu_membership
    else
      render json: @susu_membership.errors, status: :unprocessable_entity
    end
  end

  #api :DELETE, '/susu_memberships/:id', 'Destroy Susu Membership'
  def destroy
    @susu_membership.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_susu_membership
      @susu_membership = SusuMembership.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def susu_membership_params
      params.require(:susu_membership).permit(:admin, :collected, :last_payin_round, :payout_round, :user_id, :susu_id)
    end
end
