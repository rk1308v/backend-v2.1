require "rails_helper"

RSpec.describe InviteNotificationsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/invite_notifications").to route_to("invite_notifications#index")
    end

    it "routes to #new" do
      expect(:get => "/invite_notifications/new").to route_to("invite_notifications#new")
    end

    it "routes to #show" do
      expect(:get => "/invite_notifications/1").to route_to("invite_notifications#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/invite_notifications/1/edit").to route_to("invite_notifications#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/invite_notifications").to route_to("invite_notifications#create")
    end

    it "routes to #update" do
      expect(:put => "/invite_notifications/1").to route_to("invite_notifications#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/invite_notifications/1").to route_to("invite_notifications#destroy", :id => "1")
    end

  end
end
