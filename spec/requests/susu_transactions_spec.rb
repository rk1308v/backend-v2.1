require 'rails_helper'

RSpec.describe "SusuTransactions", :type => :request do
  describe "GET /susu_transactions" do
    it "works! (now write some real specs)" do
      get susu_transactions_path
      expect(response).to have_http_status(200)
    end
  end
end
