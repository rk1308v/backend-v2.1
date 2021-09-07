require "rails_helper"

RSpec.describe TransferNotificationsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/transfer_notifications").to route_to("transfer_notifications#index")
    end

    it "routes to #new" do
      expect(:get => "/transfer_notifications/new").to route_to("transfer_notifications#new")
    end

    it "routes to #show" do
      expect(:get => "/transfer_notifications/1").to route_to("transfer_notifications#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/transfer_notifications/1/edit").to route_to("transfer_notifications#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/transfer_notifications").to route_to("transfer_notifications#create")
    end

    it "routes to #update" do
      expect(:put => "/transfer_notifications/1").to route_to("transfer_notifications#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/transfer_notifications/1").to route_to("transfer_notifications#destroy", :id => "1")
    end

  end
end
