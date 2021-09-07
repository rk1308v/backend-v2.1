FactoryGirl.define do
  factory :user_transaction do
    net_amount "9.99"
    fees "9.99"
    recipient nil
    exchange_rate "9.99"
    currency_iso_from nil
    currency_iso_to nil
  end
end
