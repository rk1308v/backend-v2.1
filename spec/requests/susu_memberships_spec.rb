require 'rails_helper'

RSpec.describe "SusuMemberships", :type => :request do
  describe "GET /susu_memberships" do
    it "works! (now write some real specs)" do
      get susu_memberships_path
      expect(response).to have_http_status(200)
    end
  end
end
