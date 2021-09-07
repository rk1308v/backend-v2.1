require 'securerandom'
require 'uri'
require 'net/http'
require 'net/https'
require 'json'

class SegoviaService

    def initialize(user_transaction_id)
        @user_transaction = UserTransaction.find(user_transaction_id)
        @sender = @user_transaction.sender
        @receiver = @user_transaction.recipient.blank? ? @user_transaction.recipient_telephone : @user_transaction.recipient.telephone
        @amount = @user_transaction.net_amount
        @currency_code = ISO3166::Country.find_country_by_name(@user_transaction.country_from).currency.iso_code
        @reason = @user_transaction.description
        @receiver_country_code = ISO3166::Country.find_country_by_name(@user_transaction.country_to).currency.iso_code
    end

    def generate_header
        secret_key = ENV['SEGOVIA_SECRET']
        digest = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), secret_key, @req_body)
        @authorization = "Segovia signature=#{digest}"
    end
    
    def generate_transaction
        country = Country.find_by(name: @user_transaction.country_to)
        org = PaymentOrganisation.where(service_name: 'segovia', country_id: country.id).last
        resp_hash = @user_transaction.response_hash
        resp_hash[:payout_service] = org.blank? ? '' : org.name
        @user_transaction.update(transaction_service: SmxTransaction.const_names[:segovia_service_name], response_hash: resp_hash)
        transactions = [{
                    transactionId: @user_transaction.transaction_id,
                    provider: 'test', 
                    recipientAccountId: @receiver.class.name == 'String' ? @receiver : @receiver.id,
                    amount: @amount,
                    currency: @currency_code,
                    name: @receiver.class.name == 'String' ? @receiver : @receiver.full_name,
                    recipientId: @receiver.class.name == 'String' ? @receiver : @receiver.id,
                    reason: @reason,
                    phone: @receiver.class.name == 'String' ? @receiver : @receiver.telephone,
                    sender: {
                        customerIdentificationNumber: @sender.id,
                        accountNumber: @sender.id,
                        name: @sender.full_name,
                        phone: @sender.telephone.blank? ? '917755981687' : @sender.telephone
                    }
                }]
                
        @req_body = {clientId: 'smx-mobile-money', requestId: SecureRandom.uuid, callbackUrl: ENV['SEGOVIA_CALLBACK_URL'], transactions: transactions, callbackArgs: {user_transaction_id: @user_transaction.id, transaction_id: @user_transaction.transaction_id}}.to_json
    end

    def pay
        generate_transaction
        uri = URI.parse "#{base_link}/pay"
        @https = Net::HTTP.new(uri.host,uri.port)
        @https.use_ssl = true
        generate_header
        req = Net::HTTP::Post.new(uri.path)
        req.body = @req_body
        req['API-Version'] = '1.0'
        req['Authorization'] = @authorization
        req['Content-Type'] = 'application/json'
        response = @https.request(req)
        job_id = SegoviaStatusWorker.set(queue: 'segovia_status_queue').perform_in(15.seconds, @user_transaction.transaction_id, @user_transaction.id)
        @user_transaction.update(job_id: job_id)
        puts response.body
    end

    private
    def base_link
        return "https://payment-api.thesegovia.com/api"
    end
end