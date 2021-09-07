FactoryGirl.define do
  factory :referral_contact do
    open_lead false
    reminder_count 1
    phone_number "MyString"
    user nil
  end
end
