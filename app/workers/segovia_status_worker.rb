require 'securerandom'
require 'uri'
require 'net/http'
require 'net/https'
require 'json'

class SegoviaStatusWorker
    include Sidekiq::Worker
    sidekiq_options retry: true
    
    def perform(transaction_id, user_transaction_id)
        UserTransaction.transaction do
        	@user_transaction = UserTransaction.find(user_transaction_id)

        	uri = URI.parse "#{base_link}/transactionstatus"
            @https = Net::HTTP.new(uri.host, uri.port)
            @https.use_ssl = true
            
            req_body = {clientId: 'smx-mobile-money', requestId: SecureRandom.uuid, transactionIds: [transaction_id]}.to_json
            
            secret_key = ENV['SEGOVIA_SECRET']
            digest = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), secret_key, req_body)
            authorization = "Segovia signature=#{digest}"

            req = Net::HTTP::Post.new(uri.path)
            req.body = req_body
            req['API-Version'] = '1.0'
            req['Authorization'] = authorization
            req['Content-Type'] = 'application/json'
            response = @https.request(req)
            puts "response: #{response} - #{response.code}"
            if response.code.to_i != 200
                params = {controller: 'SegoviaStatusWorker', action: 'perform', segovia_trans_id: transaction_id, user_trans_id: user_transaction_id}
                TransactionlogService.new(params, 'Segovia server not responding', 404).fatal
            else
                puts("SegoviaStatusWorker: #{response.body}")
                SegoviaResponseWorker.set(queue: 'segovia_response_queue').perform_in(15.seconds, JSON.parse(response.body))
            end
        end
    end

    private
    def base_link
        return "https://payment-api.thesegovia.com/api"
    end
end