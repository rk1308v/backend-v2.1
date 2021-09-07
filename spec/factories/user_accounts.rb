FactoryGirl.define do
  factory :user_account do
    balance "9.99"
    send_limit "9.99"
    monthtly_send_limit "9.99"
    description "MyString"
    currency 
  end
end
