require "rails_helper"

RSpec.describe ReferralContactsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/referral_contacts").to route_to("referral_contacts#index")
    end

    it "routes to #new" do
      expect(:get => "/referral_contacts/new").to route_to("referral_contacts#new")
    end

    it "routes to #show" do
      expect(:get => "/referral_contacts/1").to route_to("referral_contacts#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/referral_contacts/1/edit").to route_to("referral_contacts#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/referral_contacts").to route_to("referral_contacts#create")
    end

    it "routes to #update" do
      expect(:put => "/referral_contacts/1").to route_to("referral_contacts#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/referral_contacts/1").to route_to("referral_contacts#destroy", :id => "1")
    end

  end
end
