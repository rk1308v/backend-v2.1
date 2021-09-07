FactoryGirl.define do
  factory :currency_exchange do
    value "9.99"
    inverse_value "9.99"
    effective_date "2016-08-10 09:08:33"
    active false
    code_from 1
    code_to 1
  end
end
