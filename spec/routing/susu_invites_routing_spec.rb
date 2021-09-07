require "rails_helper"

RSpec.describe SusuInvitesController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/susu_invites").to route_to("susu_invites#index")
    end

    it "routes to #new" do
      expect(:get => "/susu_invites/new").to route_to("susu_invites#new")
    end

    it "routes to #show" do
      expect(:get => "/susu_invites/1").to route_to("susu_invites#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/susu_invites/1/edit").to route_to("susu_invites#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/susu_invites").to route_to("susu_invites#create")
    end

    it "routes to #update" do
      expect(:put => "/susu_invites/1").to route_to("susu_invites#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/susu_invites/1").to route_to("susu_invites#destroy", :id => "1")
    end

  end
end
