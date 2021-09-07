require "rails_helper"

RSpec.describe AgentAccountsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/agent_accounts").to route_to("agent_accounts#index")
    end

    it "routes to #new" do
      expect(:get => "/agent_accounts/new").to route_to("agent_accounts#new")
    end

    it "routes to #show" do
      expect(:get => "/agent_accounts/1").to route_to("agent_accounts#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/agent_accounts/1/edit").to route_to("agent_accounts#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/agent_accounts").to route_to("agent_accounts#create")
    end

    it "routes to #update" do
      expect(:put => "/agent_accounts/1").to route_to("agent_accounts#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/agent_accounts/1").to route_to("agent_accounts#destroy", :id => "1")
    end

  end
end
