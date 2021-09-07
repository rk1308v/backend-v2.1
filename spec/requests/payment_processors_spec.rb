require 'rails_helper'

RSpec.describe "PaymentProcessors", :type => :request do
  describe "GET /payment_processors" do
    it "works! (now write some real specs)" do
      get payment_processors_path
      expect(response).to have_http_status(200)
    end
  end
end
