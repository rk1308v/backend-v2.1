FactoryGirl.define do
  sequence(:iso_alpha_2) { |n| "iso_alpha_2#{n}" }
  factory :country do
    iso_alpha_2
    dialing_code "MyString"
    name "MyString"
    flag "MyString"
  end
end
