require 'rails_helper'

context "json API" do

  describe "Create" do

    let(:user) { FactoryGirl.create :user } #create
    let(:user_account) { FactoryGirl.create :user_account, user: user } #create
    before(:each) do
      headers = { "CONTENT_TYPE" => "application/json" } #create
      post "/login", '{ "user": { "login": "'+user.email+'", "password": "12345678" } }', headers
    end
    context "with valid attributes" do
      it "should create the user_year_to_date" do
        expect { post "/api/v1/user_year_to_dates?auth_token=#{user.authtoken.token}", user_year_to_date: FactoryGirl.build(:user_year_to_date, user_account: user_account).attributes.symbolize_keys, format: :json }.to change(UserYearToDate, :count).by(1)
      end

      it 'responds with 201' do
        post "/api/v1/user_year_to_dates?auth_token=#{user.authtoken.token}", user_year_to_date: FactoryGirl.build(:user_year_to_date, user_account: user_account).attributes.symbolize_keys, format: :json
        expect(response).to have_http_status(201)
      end
    end

  end


  describe "Index" do

    let(:user) { FactoryGirl.create :user } #index
    let(:user_account) { FactoryGirl.create :user_account, user: user } #create
    before(:each) do
      headers = { "CONTENT_TYPE" => "application/json" }
      post "/login", '{ "user": { "login": "'+user.email+'", "password": "12345678" } }', headers
      3.times { FactoryGirl.create :user_year_to_date, user_account: user_account }
    end

    it "should fetch the correct number of user_year_to_dates" do
      get "/api/v1/user_year_to_dates?auth_token=#{user.authtoken.token}", page: 1, per: 2
      expect(json_response.count == 2).to eql(true)
    end

    it "should fetch the correct user_year_to_dates" do
      get "/api/v1/user_year_to_dates?auth_token=#{user.authtoken.token}", page: 1, per: 2
      json_response1 = json_response.clone
      get "/api/v1/user_year_to_dates?auth_token=#{user.authtoken.token}", page: 2, per: 2
      json_response2 = json_response.clone
      expect(json_response1.collect { |j1| j1['id'] } + json_response2.collect { |j2| j2['id'] }) .to eq(UserYearToDate.all.collect(&:id))
    end
        it "responds with 200" do
      get "/api/v1/user_year_to_dates?auth_token=#{user.authtoken.token}", format: :json
      expect(response).to have_http_status(200)
    end

  end

  describe "Show" do

    let(:user) { FactoryGirl.create :user } #show
    let(:user_account) { FactoryGirl.create :user_account, user: user } #create
    before(:each) do
      headers = { "CONTENT_TYPE" => "application/json" }
      post "/login", '{ "user": { "login": "'+user.email+'", "password": "12345678" } }', headers
      @user_year_to_date = FactoryGirl.create :user_year_to_date, user_account: user_account
    end

    it "should fetch the required user_year_to_date" do
      get "/api/v1/user_year_to_dates/#{@user_year_to_date.id}?auth_token=#{user.authtoken.token}", format: :json
      expect(json_response['id']).to eql(@user_year_to_date.id)
    end
        it "responds with 200" do
      get "/api/v1/user_year_to_dates/#{@user_year_to_date.id}?auth_token=#{user.authtoken.token}", format: :json
      expect(response).to have_http_status(200)
    end
  end

  describe "Destroy" do

    let(:user) { FactoryGirl.create :user } #destroy
    let(:user_account) { FactoryGirl.create :user_account, user: user } #create
    before(:each) do
      headers = { "CONTENT_TYPE" => "application/json" }
      post "/login", '{ "user": { "login": "'+user.email+'", "password": "12345678" } }', headers
      @user_year_to_date = FactoryGirl.create :user_year_to_date, user_account: user_account
    end

    it "should delete the required user_year_to_date" do
      delete "/api/v1/user_year_to_dates/#{@user_year_to_date.id}?auth_token=#{user.authtoken.token}", format: :json
      expect(response.body.empty?).to eql(true)
    end

    it "responds with 204" do
      delete "/api/v1/user_year_to_dates/#{@user_year_to_date.id}?auth_token=#{user.authtoken.token}", format: :json
      expect(response).to have_http_status(204)
    end

  end

  describe "Update" do

    let(:user) { FactoryGirl.create :user } #update
    let(:user_account) { FactoryGirl.create :user_account, user: user } #create
    before(:each) do
      headers = { "CONTENT_TYPE" => "application/json" }
      post "/login", '{ "user": { "login": "'+user.email+'", "password": "12345678" } }', headers
      @user_year_to_date = FactoryGirl.create :user_year_to_date, user_account: user_account
    end

    context "with valid attributes" do
      it "should update the user_year_to_date" do
        user_year_to_date = FactoryGirl.attributes_for(:user_year_to_date)
        user_year_to_date[:year] = "asdfghj"
        put "/api/v1/user_year_to_dates/#{@user_year_to_date.id}?auth_token=#{user.authtoken.token}", user_year_to_date: user_year_to_date, format: :json
        @user_year_to_date.reload
        expect(@user_year_to_date.year).to eq("asdfghj")
      end

      it 'responds with 200' do
        user_year_to_date = FactoryGirl.attributes_for(:user_year_to_date)
        user_year_to_date[:year] = "asdfghj"
        put "/api/v1/user_year_to_dates/#{@user_year_to_date.id}?auth_token=#{user.authtoken.token}", user_year_to_date: user_year_to_date, format: :json
        @user_year_to_date.reload
        expect(response).to have_http_status(200)
      end
    end

  end
end
