FactoryGirl.define do
  factory :smx_transaction do
    amount "9.99"
    status 1
    description "MyText"
    transactionable nil
  end
end
