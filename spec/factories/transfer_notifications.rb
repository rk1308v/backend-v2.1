FactoryGirl.define do
  factory :transfer_notification do
    notice_type 1
    amount "9.99"
    smx_transaction nil
    notified_by nil
  end
end
