require "rails_helper"

RSpec.describe AgentTransactionsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/agent_transactions").to route_to("agent_transactions#index")
    end

    it "routes to #new" do
      expect(:get => "/agent_transactions/new").to route_to("agent_transactions#new")
    end

    it "routes to #show" do
      expect(:get => "/agent_transactions/1").to route_to("agent_transactions#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/agent_transactions/1/edit").to route_to("agent_transactions#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/agent_transactions").to route_to("agent_transactions#create")
    end

    it "routes to #update" do
      expect(:put => "/agent_transactions/1").to route_to("agent_transactions#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/agent_transactions/1").to route_to("agent_transactions#destroy", :id => "1")
    end

  end
end
