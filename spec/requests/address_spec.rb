require 'rails_helper'

context "json API" do

  describe "Create" do

    let(:user) { FactoryGirl.create :user } #create
    before(:each) do
      headers = { "CONTENT_TYPE" => "application/json" } #create
      @address_params = FactoryGirl.build(:address, user: user).attributes
      post "/login", '{ "user": { "login": "'+user.email+'", "password": "12345678" } }', headers
    end
    context "with valid attributes" do
      it "should create the address" do
        expect { post "/api/v1/addresses?auth_token=#{user.authtoken.token}", address: @address_params, format: :json }.to change(Address, :count).by(1)
      end

      it 'responds with 201' do
        post "/api/v1/addresses?auth_token=#{user.authtoken.token}", address: @address_params, format: :json
        expect(response).to have_http_status(201)
      end
    end

  end


  describe "Index" do

    let(:user) { FactoryGirl.create :user } #index
    before(:each) do
      headers = { "CONTENT_TYPE" => "application/json" }
      post "/login", '{ "user": { "login": "'+user.email+'", "password": "12345678" } }', headers
      3.times { FactoryGirl.create :address, user: user }
    end

    it "should fetch the correct number of addresses" do
      get "/api/v1/addresses?auth_token=#{user.authtoken.token}&page=1&per=2"
      expect(json_response.count == 2).to eql(true)
    end

    it "responds with 200" do
      get "/api/v1/addresses?auth_token=#{user.authtoken.token}", format: :json
      expect(response).to have_http_status(200)
    end

  end

  describe "Show" do

    let(:user) { FactoryGirl.create :user } #show
    before(:each) do
      headers = { "CONTENT_TYPE" => "application/json" }
      @address = FactoryGirl.create :address
      post "/login", '{ "user": { "login": "'+@address.user.email+'", "password": "'+@address.user.password+'"} }', headers
    end

    it "should fetch the required address" do
      get "/api/v1/addresses/#{@address.id}?auth_token=#{@address.user.authtoken.token}", format: :json
      expect(json_response['id']).to eql(@address.id)
    end
    it "responds with 200" do
      get "/api/v1/addresses/#{@address.id}?auth_token=#{@address.user.authtoken.token}", format: :json
      expect(response).to have_http_status(200)
    end
  end

  describe "Destroy" do

    before(:each) do
      headers = { "CONTENT_TYPE" => "application/json" }
      @address = FactoryGirl.create :address
      post "/login", '{ "user": { "login": "'+@address.user.email+'", "password": "'+@address.user.password+'"} }', headers
    end

    it "should delete the required address" do
      delete "/api/v1/addresses/#{@address.id}?auth_token=#{@address.user.authtoken.token}", format: :json
      expect(response.body.empty?).to eql(true)
    end

    it "responds with 204" do
      delete "/api/v1/addresses/#{@address.id}?auth_token=#{@address.user.authtoken.token}", format: :json
      expect(response).to have_http_status(204)
    end

  end

  describe "Update" do

    before(:each) do
      headers = { "CONTENT_TYPE" => "application/json" }
      @address = FactoryGirl.create :address
      post "/login", '{ "user": { "login": "'+@address.user.email+'", "password": "'+@address.user.password+'"} }', headers
    end

    context "with valid attributes" do
      it "should update the address" do
        address = FactoryGirl.attributes_for(:address)
        address[:line1] = "asdfghj"
        put "/api/v1/addresses/#{@address.id}?auth_token=#{@address.user.authtoken.token}", address: address, format: :json
        @address.reload
        expect(@address.line1).to eq("asdfghj")
      end

      it 'responds with 200' do
        address = FactoryGirl.attributes_for(:address)
        address[:line1] = "asdfghj"
        put "/api/v1/addresses/#{@address.id}?auth_token=#{@address.user.authtoken.token}", address: address, format: :json
        @address.reload
        expect(response).to have_http_status(200)
      end
    end

  end
end
