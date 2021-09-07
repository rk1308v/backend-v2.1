require "rails_helper"

describe "Signin API" do
  let(:user) { FactoryGirl.create :user }

  context "when the credentials are correct" do
    it "creates a new Auth Token " do
      headers = { "CONTENT_TYPE" => "application/json" }
      post "/login", '{ "user": { "login": "'+user.email+'", "password": "12345678" } }', headers
      expect(response.status).to eq(200)
      expect(json_response['auth_token']).to eql (user.authtoken.token)
    end
  end

  context "when the credentials are incorrect" do
    it "returns a json with error" do
      headers = { "CONTENT_TYPE" => "application/json" }
      post "/login", '{ "user": { "login": "'+user.email+'", "password": "invalidpassword" } }', headers
      expect(response.status).to eq(400)
      expect(json_response["error"]).to eql ("Error with your email or password")
    end
  end

  context "when the user is not present" do
    it "returns user not present" do
      headers = { "CONTENT_TYPE" => "application/json" }
      post "/login", '{ "user": { "login": "klo2132182@llop11.com", "password": "12345678" } }', headers

      expect(response.status).to eq(404)
      expect(json_response["error"]).to eql ("User not found")
    end
  end

  context 'login with username' do
    it "creates a new Auth Token" do
      headers = { "CONTENT_TYPE" => "application/json" }
      post "/login", '{ "user": { "login": "'+user.username+'", "password": "12345678" } }', headers
      expect(response.status).to eq(200)
      expect(json_response['auth_token']).to eql (user.authtoken.token)
    end

    it "returns a json with error" do
      headers = { "CONTENT_TYPE" => "application/json" }
      post "/login", '{ "user": { "login": "'+user.username+'", "password": "invalidpassword" } }', headers
      expect(response.status).to eq(400)
      expect(json_response["error"]).to eql ("Error with your email or password")
    end

    it "returns user not present" do
      headers = { "CONTENT_TYPE" => "application/json" }
      post "/login", '{ "user": { "login": "klo2132182", "password": "12345678" } }', headers

      expect(response.status).to eq(404)
      expect(json_response["error"]).to eql ("User not found")
    end
  end
end

describe "when the user logs out" do
  let(:user) { FactoryGirl.create :user }

  before(:each) do
    headers = { "CONTENT_TYPE" => "application/json" }
    post "/login", '{ "user": { "login": "'+user.email+'", "password": "12345678" } }', headers
  end

  context "when the Auth Token is correct" do
    it "deletes the Auth Token from the DB" do
      headers = { "CONTENT_TYPE" => "application/json" }
      delete "/logout", '{"auth_token":"'+user.authtoken.token+'"}', headers

      expect(response.status).to eql(200)
      expect(json_response['message']).to eql ("user succesfully logged out.")
    end
  end

  context "when the Auth Token is incorrect" do
    it "returns 404" do
      headers = { "CONTENT_TYPE" => "application/json" }
      delete "/logout", '{"auth_token":"'+user.authtoken.token+'sadklsa'+'"}', headers

      expect(response.status).to eql(404)
      expect(json_response['error']).to eql ("Authtoken error/User not found")
    end
  end

end
