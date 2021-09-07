require "rails_helper"

RSpec.describe SmxTransactionsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/smx_transactions").to route_to("smx_transactions#index")
    end

    it "routes to #new" do
      expect(:get => "/smx_transactions/new").to route_to("smx_transactions#new")
    end

    it "routes to #show" do
      expect(:get => "/smx_transactions/1").to route_to("smx_transactions#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/smx_transactions/1/edit").to route_to("smx_transactions#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/smx_transactions").to route_to("smx_transactions#create")
    end

    it "routes to #update" do
      expect(:put => "/smx_transactions/1").to route_to("smx_transactions#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/smx_transactions/1").to route_to("smx_transactions#destroy", :id => "1")
    end

  end
end
