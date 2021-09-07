module GlobalEnums
    extend ActiveSupport::Concern
    included do
        enum rank: [:l1_, :l2_, :l3_]
        enum payment_type: [:smx_account_, :card_, :bank_, :cash_]
        enum status: [:pending_, :cancelled_, :completed_, :queued_] # :reversed???
        #enum trans_type: [:send_money, :request_money, :moneyin, :moneyout, :payin, :payout, :credit, :reversal, :penalty]
        enum trans_type: { send_: 0, request_: 1, cashin_: 2, cashout_: 3, payin_: 4, payout_: 5, penalty_: 6, credit_: 7, reversal_: 8}
        enum trans_error_code: {phone_not_verfied_: 1, email_not_verified_: 2, service_not_available_: 3, recep_not_present_: 4, recep_number_not_present_: 5}
        enum recipient_type: {smx_recep_: 1, non_smx_recep_: 2, international_recep_: 3}
        enum message_type: [:phone_verification_, :smx_non_smx_send_, :smx_external_send_, :smx_non_smx_cancelled_send_]
        enum const_name: {transfer_to_service_name: 'transfer_to', segovia_service_name: 'segovia', smx_service_name: 'smx_to_smx', smx_non_smx_service_name: 'smx_non_smx', smx_payout_service_name: 'SMX Account'}
        enum payment_processor: {:stripe_ => 'stripe', :braintree_ => 'braintree'}
    end
end
