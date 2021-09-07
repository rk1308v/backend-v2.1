require "rails_helper"

RSpec.describe AdminTransactionsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/admin_transactions").to route_to("admin_transactions#index")
    end

    it "routes to #new" do
      expect(:get => "/admin_transactions/new").to route_to("admin_transactions#new")
    end

    it "routes to #show" do
      expect(:get => "/admin_transactions/1").to route_to("admin_transactions#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/admin_transactions/1/edit").to route_to("admin_transactions#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/admin_transactions").to route_to("admin_transactions#create")
    end

    it "routes to #update" do
      expect(:put => "/admin_transactions/1").to route_to("admin_transactions#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/admin_transactions/1").to route_to("admin_transactions#destroy", :id => "1")
    end

  end
end
