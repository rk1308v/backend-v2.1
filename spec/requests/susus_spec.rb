require 'rails_helper'

RSpec.describe "Susus", :type => :request do
  describe "GET /susus" do
    it "works! (now write some real specs)" do
      get susus_path
      expect(response).to have_http_status(200)
    end
  end
end
