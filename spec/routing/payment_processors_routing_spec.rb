require "rails_helper"

RSpec.describe PaymentProcessorsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/payment_processors").to route_to("payment_processors#index")
    end

    it "routes to #new" do
      expect(:get => "/payment_processors/new").to route_to("payment_processors#new")
    end

    it "routes to #show" do
      expect(:get => "/payment_processors/1").to route_to("payment_processors#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/payment_processors/1/edit").to route_to("payment_processors#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/payment_processors").to route_to("payment_processors#create")
    end

    it "routes to #update" do
      expect(:put => "/payment_processors/1").to route_to("payment_processors#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/payment_processors/1").to route_to("payment_processors#destroy", :id => "1")
    end

  end
end
