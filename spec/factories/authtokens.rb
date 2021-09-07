FactoryGirl.define do
  factory :authtoken do
    token "MyString"
    last_used_at "2016-07-30 20:08:51"
    sign_in_ip ""
    user_agent "MyString"
    device_id "MyString"
    user 
  end
end
