require 'rails_helper'

RSpec.describe "SusuNotifications", :type => :request do
  describe "GET /susu_notifications" do
    it "works! (now write some real specs)" do
      get susu_notifications_path
      expect(response).to have_http_status(200)
    end
  end
end
