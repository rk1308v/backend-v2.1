require 'rails_helper'

RSpec.describe "SusuInvites", :type => :request do
  describe "GET /susu_invites" do
    it "works! (now write some real specs)" do
      get susu_invites_path
      expect(response).to have_http_status(200)
    end
  end
end
