require 'rails_helper'

context "json API" do

  describe "Create" do

    let(:user) { FactoryGirl.create :user } #create
    let(:currency) { FactoryGirl.create :currency }
    before(:each) do
      headers = { "CONTENT_TYPE" => "application/json" } #create
      @user_account_params = FactoryGirl.build(:user_account, user: user, currency: currency).attributes
      post "/login", '{ "user": { "login": "'+user.email+'", "password": "12345678" } }', headers
    end
    context "with valid attributes" do
      it "should create the user_account" do
        expect { post "/api/v1/user_accounts?auth_token=#{user.authtoken.token}", user_account: @user_account_params, format: :json }.to change(UserAccount, :count).by(1)
      end

      it 'responds with 201' do
        post "/api/v1/user_accounts?auth_token=#{user.authtoken.token}", user_account: @user_account_params, format: :json
        expect(response).to have_http_status(201)
      end
    end

  end


  describe "Index" do

    let(:user) { FactoryGirl.create :user } #index
    let(:currency) { FactoryGirl.create :currency }
    before(:each) do
      headers = { "CONTENT_TYPE" => "application/json" }
      post "/login", '{ "user": { "login": "'+user.email+'", "password": "12345678" } }', headers
      3.times { FactoryGirl.create(:user_account, user: user, currency: currency) }
    end

    it "should fetch the correct number of user_accounts" do
      get "/api/v1/user_accounts?auth_token=#{user.authtoken.token}", page: 1, per: 2
      expect(json_response.count == 2).to eql(true)
    end

    it "should fetch the correct user_accounts" do
      get "/api/v1/user_accounts?auth_token=#{user.authtoken.token}", page: 1, per: 2
      json_response1 = json_response.clone
      get "/api/v1/user_accounts?auth_token=#{user.authtoken.token}", page: 2, per: 2
      json_response2 = json_response.clone
      expect(json_response1.collect { |j1| j1['id'] } + json_response2.collect { |j2| j2['id'] }) .to eq(UserAccount.all.collect(&:id))
    end
        it "responds with 200" do
      get "/api/v1/user_accounts?auth_token=#{user.authtoken.token}", format: :json
      expect(response).to have_http_status(200)
    end

  end

  describe "Show" do

    let(:user) { FactoryGirl.create :user } #show
    let(:currency) { FactoryGirl.create :currency }
    before(:each) do
      headers = { "CONTENT_TYPE" => "application/json" }
      post "/login", '{ "user": { "login": "'+user.email+'", "password": "12345678" } }', headers
      @user_account = FactoryGirl.create(:user_account, user: user, currency: currency)
    end

    it "should fetch the required user_account" do
      get "/api/v1/user_accounts/#{@user_account.id}?auth_token=#{user.authtoken.token}", format: :json
      expect(json_response['id']).to eql(@user_account.id)
    end
        it "responds with 200" do
      get "/api/v1/user_accounts/#{@user_account.id}?auth_token=#{user.authtoken.token}", format: :json
      expect(response).to have_http_status(200)
    end
  end

  describe "Destroy" do

    let(:user) { FactoryGirl.create :user } #destroy
    let(:currency) { FactoryGirl.create :currency }
    before(:each) do
      headers = { "CONTENT_TYPE" => "application/json" }
      post "/login", '{ "user": { "login": "'+user.email+'", "password": "12345678" } }', headers
      @user_account = FactoryGirl.create(:user_account, user: user, currency: currency)
    end

    it "should delete the required user_account" do
      delete "/api/v1/user_accounts/#{@user_account.id}?auth_token=#{user.authtoken.token}", format: :json
      expect(response.body.empty?).to eql(true)
    end

    it "responds with 204" do
      delete "/api/v1/user_accounts/#{@user_account.id}?auth_token=#{user.authtoken.token}", format: :json
      expect(response).to have_http_status(204)
    end

  end

  describe "Update" do

    let(:user) { FactoryGirl.create :user } #update
    let(:currency) { FactoryGirl.create :currency }
    before(:each) do
      headers = { "CONTENT_TYPE" => "application/json" }
      post "/login", '{ "user": { "login": "'+user.email+'", "password": "12345678" } }', headers
      @user_account = FactoryGirl.create(:user_account, user: user, currency: currency)
    end

    context "with valid attributes" do
      it "should update the user_account" do
        user_account = FactoryGirl.attributes_for(:user_account)
        user_account[:description] = "asdfghj"
        put "/api/v1/user_accounts/#{@user_account.id}?auth_token=#{user.authtoken.token}", user_account: user_account, format: :json
        @user_account.reload
        expect(@user_account.description).to eq("asdfghj")
      end

      it 'responds with 200' do
        user_account = FactoryGirl.attributes_for(:user_account)
        user_account[:description] = "asdfghj"
        put "/api/v1/user_accounts/#{@user_account.id}?auth_token=#{user.authtoken.token}", user_account: user_account, format: :json
        @user_account.reload
        expect(response).to have_http_status(200)
      end
    end

  end
end
