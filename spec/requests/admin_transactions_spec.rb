require 'rails_helper'

RSpec.describe "AdminTransactions", :type => :request do
  describe "GET /admin_transactions" do
    it "works! (now write some real specs)" do
      get admin_transactions_path
      expect(response).to have_http_status(200)
    end
  end
end
