FactoryGirl.define do
  factory :fees_and_commission do
    amount_from "9.99"
    amount_to "9.99"
    amount "9.99"
    percentage "9.99"
    percent_based false
    active false
    fc_type 1
    rank 1
    money_type 1
    tansaction_type 1
    sending_country nil
    receiving_country nil
  end
end
