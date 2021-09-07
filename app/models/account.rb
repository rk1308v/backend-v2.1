class Account < ApplicationRecord

  # Autocode: Callbacks
  # Relationships
  belongs_to :user
  belongs_to :profile, polymorphic: true
  
  # Autocode: Accept Nested Attributes
  # File Upload
  # Validations
  validates :user_id, presence: true
  # Soft Destroy

  def self.create_user_account user
  	@user_account = UserAccount.create!(balance: 0.00)
  	@account = Account.create!(profile: @user_account, user_id: user.id)
  end

  def self.create_agent_account user, params
    company_name = params[:company_name]
    description = params[:account_description]
    @agent_account = AgentAccount.create!(user_id: user.id, company_name: company_name, description: description)
    @account = Account.create!(profile: @agent_account, user_id: user.id)
  end

end
