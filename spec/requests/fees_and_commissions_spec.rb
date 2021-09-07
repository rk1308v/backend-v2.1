require 'rails_helper'

RSpec.describe "FeesAndCommissions", :type => :request do
  describe "GET /fees_and_commissions" do
    it "works! (now write some real specs)" do
      get fees_and_commissions_path
      expect(response).to have_http_status(200)
    end
  end
end
