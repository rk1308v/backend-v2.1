
require "rails_helper"

describe "Signup API" do
  context "when it's an email login" do
    it "creates a new user with basic/email login" do
      headers = { "CONTENT_TYPE" => "application/json" }
      post '/signup', '{ "user": { "email":"abc@po.com", "password":"abcdabcd", "password_confirmation":"abcdabcd"} }', headers
      expect(response.status).to eq(200)
      expect(json_response['message']).to eq("abc@po.com was succesfully created")
      expect(json_response['auth_token']).to be_truthy
    end
  end

  context 'when it\'s an username login' do
    it "creates a new user login" do
      headers = { "CONTENT_TYPE" => "application/json" }
      post '/signup', '{ "user": { "email":"abc@po.com", "username": "abc", "password":"abcdabcd", "password_confirmation":"abcdabcd"} }', headers
      expect(response.status).to eq(200)
      expect(json_response['message']).to eq("abc@po.com was succesfully created")
      expect(json_response['auth_token']).to be_truthy
    end
  end

  context "when it's a social login" do

    context "when the access token is invalid" do
      it "creates a new user with social login - facebook(Invalid access_token)" do
        stub_request(:get, "https://graph.facebook.com/v2.5/me?access_token=CAAClzXtUEBAySLMcz6twBHdBOrqt3ZAvtAYCxrWPIuEl7UoIhHbQTfAQVFPCDi0pYIbNNKEZBxeZAq1MYt1kwN6rCNpwMRZB05P3S1SSq3wE6xWvXYpwcHp9ji2LksE5oaZAoB0yJhWMxIJ6MgH8PkZCEg7zZA1ZA6x0br6mKg9N9UBwEXhGNBhWXeLzuU4f9sandFVrH4qbPk93oj37wjknpIXy4ZAInrMHeeYkpxEoYu7xp7BJ").
        with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Host'=>'graph.facebook.com', 'User-Agent'=>'Ruby'}).
        to_return(:status => 200, :body => "Access Token is Invalid - Oauth Exception", :headers => {})
        # expect(response.status).to eq(400)
        # expect(json_response["error"]).to eq("Access Token is Invalid - Oauth Exception")
      end
    end

    context "when the access token is valid" do
      it "creates a new user with social login - facebook(Correct access_token)" do
        stub_request(:get, "https://graph.facebook.com/v2.5/me?access_token=CAAFVE5QDB2UBADSBILA7ygypqFYDEG3QxlVNEbnnoyTKEUqBjRMbZBMHhd5SCfNS2IoJy7zvZAryiiwYBDc9uzy34ufSZCe5WSwDHeYHSJdRi0MasHa9LWFCbFMezhWNXFldyXml7lZAZCe0uIYF7VeXeL4QT3ZAFEZAL4q4GLI7tYw6f7wGnYtnNmWO7pcne82XdX81ZAoOjwZDZD").
        with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Host'=>'graph.facebook.com', 'User-Agent'=>'Ruby'}).
        to_return(:status => 200, :body => "2LiSeyfVmDS4Hjd5ndaBUhDJ", :headers => {})
        # byebug
        # expect(response.status).to eq(200)
        # expect(json_response['auth_token']).to be_truthy
      end
    end
  end

end
