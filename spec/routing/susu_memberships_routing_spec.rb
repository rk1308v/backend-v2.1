require "rails_helper"

RSpec.describe SusuMembershipsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/susu_memberships").to route_to("susu_memberships#index")
    end

    it "routes to #new" do
      expect(:get => "/susu_memberships/new").to route_to("susu_memberships#new")
    end

    it "routes to #show" do
      expect(:get => "/susu_memberships/1").to route_to("susu_memberships#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/susu_memberships/1/edit").to route_to("susu_memberships#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/susu_memberships").to route_to("susu_memberships#create")
    end

    it "routes to #update" do
      expect(:put => "/susu_memberships/1").to route_to("susu_memberships#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/susu_memberships/1").to route_to("susu_memberships#destroy", :id => "1")
    end

  end
end
