FactoryGirl.define do
  factory :address do
    line1 "MyString"
    line2 "MyString"
    line3 "MyString"
    city "MyString"
    postcode_prefix "MyString"
    zip_postcode "MyString"
    state_province_county "MyString"
    description "MyText"
    address_type "physical"
    user
    country
  end
end
