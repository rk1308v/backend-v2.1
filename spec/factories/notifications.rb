FactoryGirl.define do
  factory :notification do
    read false
    notice "MyString"
    user nil
    noticeable nil
  end
end
