require 'rails_helper'

RSpec.describe "AgentAccounts", :type => :request do
  describe "GET /agent_accounts" do
    it "works! (now write some real specs)" do
      get agent_accounts_path
      expect(response).to have_http_status(200)
    end
  end
end
