require 'rails_helper'

RSpec.describe "InviteNotifications", :type => :request do
  describe "GET /invite_notifications" do
    it "works! (now write some real specs)" do
      get invite_notifications_path
      expect(response).to have_http_status(200)
    end
  end
end
