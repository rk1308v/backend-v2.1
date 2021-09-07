FactoryGirl.define do
  factory :payment_method do
    issuer_name "MyString"
    valid false
    token "MyString"
    token_valid_until ""
    payment_type 1
    card_type 1
    description "MyText"
    Country nil
    user nil
  end
end
