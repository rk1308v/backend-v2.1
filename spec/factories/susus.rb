FactoryGirl.define do
  factory :susu do
    name ""
    members_count 1
    rounds_count 1
    current_round 1
    days_per_round 1
    payin_amount "9.99"
    payout_amount "9.99"
    fees "9.99"
    started_at "2017-01-23 07:55:55"
    ended_at "2017-01-23 07:55:55"
    status 1
    description "MyText"
  end
end
