require 'rails_helper'

context "json API" do

  describe "Create" do

    let(:user) { FactoryGirl.create :user } #create
    before(:each) do
      headers = { "CONTENT_TYPE" => "application/json" } #create
      post "/login", '{ "user": { "login": "'+user.email+'", "password": "12345678" } }', headers
    end

    context "with valid attributes" do
      it "should create the currency_exchange" do
        expect { post "/api/v1/currency_exchanges?auth_token=#{user.authtoken.token}", currency_exchange: FactoryGirl.build(:currency_exchange).attributes.symbolize_keys, format: :json }.to change(CurrencyExchange, :count).by(1)
      end

      it 'responds with 201' do
        post "/api/v1/currency_exchanges?auth_token=#{user.authtoken.token}", currency_exchange: FactoryGirl.build(:currency_exchange).attributes.symbolize_keys, format: :json
        expect(response).to have_http_status(201)
      end
    end

  end


  describe "Index" do

    let(:user) { FactoryGirl.create :user } #index
    before(:each) do
      headers = { "CONTENT_TYPE" => "application/json" }
      post "/login", '{ "user": { "login": "'+user.email+'", "password": "12345678" } }', headers
      3.times { FactoryGirl.create :currency_exchange}
    end

    it "should fetch the correct number of currency_exchanges" do
      get "/api/v1/currency_exchanges?auth_token=#{user.authtoken.token}", page: 1, per: 2
      expect(json_response.count == 2).to eql(true)
    end

    it "should fetch the correct currency_exchanges" do
      get "/api/v1/currency_exchanges?auth_token=#{user.authtoken.token}", page: 1, per: 2
      json_response1 = json_response.clone
      get "/api/v1/currency_exchanges?auth_token=#{user.authtoken.token}", page: 2, per: 2
      json_response2 = json_response.clone
      expect(json_response1.collect { |j1| j1['id'] } + json_response2.collect { |j2| j2['id'] }) .to eq(CurrencyExchange.all.collect(&:id))
    end
        it "responds with 200" do
      get "/api/v1/currency_exchanges?auth_token=#{user.authtoken.token}", format: :json
      expect(response).to have_http_status(200)
    end

  end

  describe "Show" do

    let(:user) { FactoryGirl.create :user } #show
    before(:each) do
      headers = { "CONTENT_TYPE" => "application/json" }
      post "/login", '{ "user": { "login": "'+user.email+'", "password": "12345678" } }', headers
      @currency_exchange = FactoryGirl.create :currency_exchange
    end

    it "should fetch the required currency_exchange" do
      get "/api/v1/currency_exchanges/#{@currency_exchange.id}?auth_token=#{user.authtoken.token}", format: :json
      expect(json_response['id']).to eql(@currency_exchange.id)
    end
        it "responds with 200" do
      get "/api/v1/currency_exchanges/#{@currency_exchange.id}?auth_token=#{user.authtoken.token}", format: :json
      expect(response).to have_http_status(200)
    end
  end

  describe "Destroy" do

    let(:user) { FactoryGirl.create :user } #destroy
    before(:each) do
      headers = { "CONTENT_TYPE" => "application/json" }
      post "/login", '{ "user": { "login": "'+user.email+'", "password": "12345678" } }', headers
      @currency_exchange = FactoryGirl.create :currency_exchange
    end

    it "should delete the required currency_exchange" do
      delete "/api/v1/currency_exchanges/#{@currency_exchange.id}?auth_token=#{user.authtoken.token}", format: :json
      expect(response.body.empty?).to eql(true)
    end

    it "responds with 204" do
      delete "/api/v1/currency_exchanges/#{@currency_exchange.id}?auth_token=#{user.authtoken.token}", format: :json
      expect(response).to have_http_status(204)
    end

  end

  describe "Update" do

    let(:user) { FactoryGirl.create :user } #update
    before(:each) do
      headers = { "CONTENT_TYPE" => "application/json" }
      post "/login", '{ "user": { "login": "'+user.email+'", "password": "12345678" } }', headers
      @currency_exchange = FactoryGirl.create :currency_exchange
    end

    context "with valid attributes" do
      it "should update the currency_exchange" do
        currency_exchange = FactoryGirl.attributes_for(:currency_exchange)
        currency_exchange[:value] = "10.99"
        put "/api/v1/currency_exchanges/#{@currency_exchange.id}?auth_token=#{user.authtoken.token}", currency_exchange: currency_exchange, format: :json
        @currency_exchange.reload
        expect(@currency_exchange.value).to eq(10.99)
      end

      it 'responds with 200' do
        currency_exchange = FactoryGirl.attributes_for(:currency_exchange)
        currency_exchange[:code_to] = "asdfghj"
        put "/api/v1/currency_exchanges/#{@currency_exchange.id}?auth_token=#{user.authtoken.token}", currency_exchange: currency_exchange, format: :json
        @currency_exchange.reload
        expect(response).to have_http_status(200)
      end
    end

  end
end
