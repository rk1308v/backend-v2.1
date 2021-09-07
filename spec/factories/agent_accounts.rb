FactoryGirl.define do
  factory :agent_account do
    company_name "MyString"
    money_in "9.99"
    money_out "9.99"
    commission "9.99"
    payin_amount "9.99"
    description "MyText"
    user nil
    currency nil
  end
end
