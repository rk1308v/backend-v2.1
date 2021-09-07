FactoryGirl.define do
  factory :susu_membership do
    admin false
    collected false
    last_payin_round 1
    payout_round 1
    user nil
    susu nil
  end
end
