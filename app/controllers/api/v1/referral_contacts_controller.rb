class Api::V1::ReferralContactsController < Api::V1::BaseController
  before_action :set_referral_contact, only: [:show, :update, :destroy]

  def_param_group :referral_contact do
    param :referral_contact, Hash, required: true, action_aware: true do
      param :phone_number, String, required: true, allow_nil: false
      param :reminder_count, Integer, required: true, allow_nil: false
      param :open_lead,[true, false], required: true, allow_nil: false
      param :user_id, String, required: true, allow_nil: false
    end
  end

  #api :GET, '/referral_contacts', 'List Referal Contacts'
  def index
    @referral_contacts = @user.referralContact.page(params[:page]).per(params[:per])

    render json: @referral_contacts
  end

  #api :GET, '/referral_contacts/:id', 'Show Referal Contact'
  def show
    render json: @referral_contact
  end

  #api :POST, '/referral_contacts', 'Create Referal Contact'
  param_group :referral_contact
  def create
    @referral_contact = @user.referralContact.new(referral_contact_params)

    if @referral_contact.save
      render json: @referral_contact, status: :created, location: @referral_contact
    else
      render json: @referral_contact.errors, status: :unprocessable_entity
    end
  end

  #api :PUT, '/referral_contacts/:id', 'Update Referal Contact'
  param_group :referral_contact
  def update
    if @referral_contact.update(referral_contact_params)
      render json: @referral_contact
    else
      render json: @referral_contact.errors, status: :unprocessable_entity
    end
  end

  #api :DELETE, '/referral_contacts/:id', 'Destroy Referal Contact'
  def destroy
    @referral_contact.destroy
  end

  private
    #api Use callbacks to share common setup or constraints between actions.
    def set_referral_contact
      @referral_contact = ReferralContact.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def referral_contact_params
      params.require(:referral_contact).permit(:open_lead, :reminder_count, :phone_number, :user_id)
    end
end
