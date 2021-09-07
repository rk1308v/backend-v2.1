require "rails_helper"

RSpec.describe FeesAndCommissionsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/fees_and_commissions").to route_to("fees_and_commissions#index")
    end

    it "routes to #new" do
      expect(:get => "/fees_and_commissions/new").to route_to("fees_and_commissions#new")
    end

    it "routes to #show" do
      expect(:get => "/fees_and_commissions/1").to route_to("fees_and_commissions#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/fees_and_commissions/1/edit").to route_to("fees_and_commissions#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/fees_and_commissions").to route_to("fees_and_commissions#create")
    end

    it "routes to #update" do
      expect(:put => "/fees_and_commissions/1").to route_to("fees_and_commissions#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/fees_and_commissions/1").to route_to("fees_and_commissions#destroy", :id => "1")
    end

  end
end
