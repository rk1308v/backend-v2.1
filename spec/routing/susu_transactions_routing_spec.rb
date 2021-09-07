require "rails_helper"

RSpec.describe SusuTransactionsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/susu_transactions").to route_to("susu_transactions#index")
    end

    it "routes to #new" do
      expect(:get => "/susu_transactions/new").to route_to("susu_transactions#new")
    end

    it "routes to #show" do
      expect(:get => "/susu_transactions/1").to route_to("susu_transactions#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/susu_transactions/1/edit").to route_to("susu_transactions#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/susu_transactions").to route_to("susu_transactions#create")
    end

    it "routes to #update" do
      expect(:put => "/susu_transactions/1").to route_to("susu_transactions#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/susu_transactions/1").to route_to("susu_transactions#destroy", :id => "1")
    end

  end
end
