require "rails_helper"

RSpec.describe SusuNotificationsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/susu_notifications").to route_to("susu_notifications#index")
    end

    it "routes to #new" do
      expect(:get => "/susu_notifications/new").to route_to("susu_notifications#new")
    end

    it "routes to #show" do
      expect(:get => "/susu_notifications/1").to route_to("susu_notifications#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/susu_notifications/1/edit").to route_to("susu_notifications#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/susu_notifications").to route_to("susu_notifications#create")
    end

    it "routes to #update" do
      expect(:put => "/susu_notifications/1").to route_to("susu_notifications#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/susu_notifications/1").to route_to("susu_notifications#destroy", :id => "1")
    end

  end
end
