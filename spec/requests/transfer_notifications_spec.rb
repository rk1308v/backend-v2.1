require 'rails_helper'

RSpec.describe "TransferNotifications", :type => :request do
  describe "GET /transfer_notifications" do
    it "works! (now write some real specs)" do
      get transfer_notifications_path
      expect(response).to have_http_status(200)
    end
  end
end
