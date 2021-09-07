require 'rails_helper'

RSpec.describe "ReferralContacts", :type => :request do
  describe "GET /referral_contacts" do
    it "works! (now write some real specs)" do
      get referral_contacts_path
      expect(response).to have_http_status(200)
    end
  end
end
