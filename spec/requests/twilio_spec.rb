require "rails_helper"

describe "Twilio API" do

  let(:user) { FactoryGirl.create :user } #create
  before(:each) do
    headers = { "CONTENT_TYPE" => "application/json" } #create
    post "/login", '{ "user": { "login": "'+user.email+'", "password": "12345678" } }', headers
  end

  context "when a message is sent using Twilio" do
    it "send a 4 digit verification code to the user" do
      stub_request(:post, "https://api.twilio.com/2010-04-01/Accounts/AKIAJCBRNXXUQ/SMS/Messages.json").
      with(:body => {"Body"=>"Your Verification Code is - 2083", "From"=>"+11234567890", "To"=>"12345678"},
      :headers => {'Accept'=>'application/json', 'Accept-Charset'=>'utf-8', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization'=>'Basic QUtJQUpDQlJOWFhVUTpBS0lBSlJOWFhVUQ==', 'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'twilio-ruby/4.11.1 (ruby/x86_64-darwin15 2.3.0-p0)'}).
      to_return(:status => 200, :body => "", :headers => {})
      expect(response.status).to eq(200)
    end
  end
end
