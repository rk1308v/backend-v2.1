require 'rails_helper'

RSpec.describe "AgentTransactions", :type => :request do
  describe "GET /agent_transactions" do
    it "works! (now write some real specs)" do
      get agent_transactions_path
      expect(response).to have_http_status(200)
    end
  end
end
