require "open-uri"
require 'csv'
require 'securerandom'
require 'uri'
require 'net/http'
require 'net/https'
require 'json'

#####################  SMX Countries   #######################
["Burkina Faso", "United States"].each do |c_name|
    c = ISO3166::Country.find_country_by_name c_name
    if c
        if Country.exists?(iso_alpha_3: c.alpha3.downcase) == false
            #cntry = Country.create!(iso_alpha_3: c.alpha3.downcase, name: c.name, susu: true, transfer: true)
            cntry = Country.create!(iso_alpha_3: c.alpha3, name: c.name, susu: true, transfer: true)
            if c_name == 'United States'
                cntry.flag = URI.parse('https://s3-us-west-2.amazonaws.com/smx-image-bucket/images/countries/flags/2/micro.png')
                cntry.save
            else
                cntry.flag = URI.parse('https://s3-us-west-2.amazonaws.com/smx-image-bucket/images/countries/flags/1/micro.png')
                cntry.save
            end
        end
    end
end

##################### Currency exchange #####################
# [[Country.first.iso_alpha_3, Country.last.iso_alpha_3], [Country.last.iso_alpha_3, Country.first.iso_alpha_3]].each do |alpha_data|
#     if CurrencyExchange.exists?(country_from: alpha_data[0], country_to: alpha_data[1]) == false
#         cx = CurrencyExchange.create!(value: 2,
#             effective_date: Time.now, 
#             active: true, 
#             country_from: alpha_data[0], 
#             country_to: alpha_data[1])
#     end
# end

# if Rails.env != 'production'
#     # Create users with $1000 balance
#     40.times do |index|
#         if User.exists?(email: "email#{index}@domain.com") == false
#             @user = User.create!(first_name: "FirstName#{index}",
#                 last_name: "LastName#{index}",
#                 telephone: 9872349000 + index,
#                 active: true,
#                 description: "desc",
#                 email: "email#{index}@domain.com",
#                 password: "Abc123",
#                 password_confirmation: "Abc123",
#                 country: "USA",
#                 email_verified: true,
#                 phone_verified: true,
#                 username: "Username#{index}"
#                 )
#             @user_account = UserAccount.create!(balance: 1000)
#             @account = Account.create!(profile: @user_account, user_id: @user.id)
#             @picture = Picture.create!(user_id: @user.id)
#         end
#     end
# end

[SmxTransaction.const_names[:segovia_service_name], SmxTransaction.const_names[:transfer_to_service_name], SmxTransaction.const_names[:smx_service_name], SmxTransaction.const_names[:smx_non_smx_service_name]].each do |serv|
    payment_service = PaymentService.find_by(service_name: serv)
    if payment_service.blank?
        payment_service = PaymentService.new(service_name: serv)
        if serv == SmxTransaction.const_names[:segovia_service_name]
            payment_service.api_key = "AxdP2So5xigjTFOLFHR7d4oKJM3jvs11Zqn0lU3hyjZC"
            payment_service.isactive = true
            payment_service.service_description = "Segovia Payment service"
        elsif serv == SmxTransaction.const_names[:transfer_to_service_name]
            payment_service.api_key = "AxdP2So5xigjTFOLFHR7d4oKJM3jvs11Zqn0lU3hyjZC"
            payment_service.isactive = false
            payment_service.service_description = "TransferTo Payment service"
        elsif serv == SmxTransaction.const_names[:smx_service_name]
            payment_service.api_key = "AxdP2So5xigjTFOLFHR7d4oKJM3jvs11Zqn0lU3hyjZC"
            payment_service.isactive = true
            payment_service.service_description = "SMX to SMX service with card"

            country = Country.find_by(iso_alpha_3: 'USA')
            payment_org = PaymentOrganisation.find_or_initialize_by(country_id: country.id, service_name: SmxTransaction.const_names[:smx_service_name], name: 'SMX')
            payment_org.country_id = country.id
            payment_org.service_name = SmxTransaction.const_names[:smx_service_name].to_s
            payment_org.name = 'SMX'
            payment_org.availability = 'Live'
            payment_org.save
        elsif serv == SmxTransaction.const_names[:smx_non_smx_service_name]
            payment_service.api_key = "AxdP2So5xigjTFOLFHR7d4oKJM3jvs11Zqn0lU3hyjZC"
            payment_service.isactive = true
            payment_service.service_description = "SMX to Non SMX service"

            country = Country.find_by(iso_alpha_3: 'USA')
            payment_org = PaymentOrganisation.find_or_initialize_by(country_id: country.id, service_name: SmxTransaction.const_names[:smx_non_smx_service_name], name: 'SMX-NON-SMX')
            payment_org.country_id = country.id
            payment_org.service_name = SmxTransaction.const_names[:smx_non_smx_service_name].to_s
            payment_org.name = 'SMX-NON-SMX'
            payment_org.availability = 'Live'
            payment_org.save
        end
        payment_service.save
    end
end

# Add transferto countries & methods
transfer_to_org_data = []
CSV.foreach(Rails.root.join('public/country_data/africa_countries.csv'), headers: true) do |row|
    transfer_to_org_data << row.to_h
end
countries_list = transfer_to_org_data.map{|p| p["COUNTRY"]}
countries_list.each do |country_name|
    country_name = country_name.strip
    country = Country.find_by(name: country_name)
    iso_country = ISO3166::Country.find_country_by_name country_name
    if country.blank? && iso_country.present?
        flag_file_path = Rails.root.join("public/country_data/country_flags/#{iso_country.alpha2.downcase}.png")
        flag = File.open(flag_file_path) if File.exists?(flag_file_path)
        country = Country.create(iso_alpha_3: iso_country.alpha3, name: country_name, transfer: true, susu: true, flag: flag)
    end
    if iso_country.blank?
        puts "Cannot create: #{country_name}"
    else
        if country.present?
            org_list = transfer_to_org_data.select{|org| org["COUNTRY"] == country.name}
            org_list.each do |list_data|
                termination_type = 0
                if list_data['TERMINATION TYPE'].to_s == 'Mobile Money Account'
                    termination_type = 0
                elsif list_data['TERMINATION TYPE'].to_s == 'Bank Account Deposits'
                    termination_type = 1
                elsif list_data['TERMINATION TYPE'].to_s == 'Cash Pick Up'
                    termination_type = 2
                end
                
                payment_org = PaymentOrganisation.find_or_initialize_by(country_id: country.id, service_name: SmxTransaction.const_names[:transfer_to_service_name], name: list_data['ORGANISATION NAMES'].to_s, termination_type: termination_type, service_coverage: list_data['SERVICE COVERAGE'].to_s)
                payment_org.country_id = country.id
                payment_org.service_name = SmxTransaction.const_names[:transfer_to_service_name].to_s
                payment_org.name = list_data['ORGANISATION NAMES'].to_s
                payment_org.termination_type = termination_type
                payment_org.service_coverage = list_data['SERVICE COVERAGE'].to_s
                payment_org.availability = list_data['AVAILABILITY'].to_s
                payment_org.business_model = list_data['BUSINESS MODEL'].to_s
                payment_org.payment_speed = list_data['PAYMENT SPEED'].to_s
                payment_org.benificiary_lookup = list_data['BENEFICIARY LOOKUP'].to_s
                payment_org.commission_less_hundred = list_data['TRANSFERTO COMMISSION (< $100)'].to_s.scan(/(\d+[.,]\d+)/).flatten.first
                payment_org.commission_greater_hundred = list_data['TRANSFERTO COMMISSION (>$100)'].to_s.scan(/(\d+[.,]\d+)/).flatten.first
                payment_org.min_commission = list_data['MINIMUM COMMISSION'].to_s.scan(/(\d+[.,]\d+)/).flatten.first
                payment_org.save
            end
        end
    end
end


@req_body = {clientId: 'smx-mobile-money', requestId: SecureRandom.uuid }.to_json
secret_key = ENV['SEGOVIA_SECRET']
digest = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), secret_key, @req_body)
puts("Signature: #{digest}")
@authorization = "Segovia signature=#{digest}"
uri = URI.parse "https://payment-api.thesegovia.com/api/paymentproviders"
@https = Net::HTTP.new(uri.host,uri.port)
@https.use_ssl = true

secret_key = ENV['SEGOVIA_SECRET']
digest = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), secret_key, @req_body)
@authorization = "Segovia signature=#{digest}"
        
req = Net::HTTP::Post.new(uri.path)
req.body = @req_body
req['API-Version'] = '1.0'
req['Authorization'] = @authorization
req['Content-Type'] = 'application/json'
response = @https.request(req)
if response.code.to_i == 200
    data = JSON.parse response.body
    puts data["paymentProviders"]
    if data
        data["paymentProviders"].each do |d|
            if d.has_key? "supportedCurrencies"
                d["supportedCurrencies"].each do |currency|
                    iso_country = ISO3166::Country.find_country_by_currency_code currency
                    country = Country.find_by(name: iso_country.name)
                    if country.blank?
                        flag_file_path = Rails.root.join("public/country_data/country_flags/#{iso_country.alpha2.downcase}.png")
                        flag = File.open(flag_file_path) if File.exists?(flag_file_path)
                        country = Country.create(iso_alpha_3: iso_country.alpha3, name: iso_country.name, transfer: true, susu: true, flag: flag)
                    end
                    if country
                        payment_org = PaymentOrganisation.find_or_initialize_by(country_id: country.id, service_name: SmxTransaction.const_names[:segovia_service_name], name: d["name"])
                        payment_org.country_id = country.id
                        payment_org.service_name = SmxTransaction.const_names[:segovia_service_name].to_s
                        payment_org.name = d["name"].to_s
                        payment_org.termination_type = 0
                        payment_org.availability = 'Live'
                        payment_org.commission_less_hundred = 0.01
                        payment_org.commission_greater_hundred = 0.01
                        payment_org.min_commission = 0.01
                        payment_org.save
                    end
                end
            end
        end
    end
end

payment_processor = PaymentProcessor.find_by(name: 'stripe')
if payment_processor.blank?
    PaymentProcessor.create(name: 'stripe', api_key: 'pk_test_idVcTQhmG9oYcwz9iX07soWj', api_secret: 'sk_test_d5Yy0gi4fsMbERNeU9lWJb3V', is_live: true, country_id: Country.first.id)
end
puts "All data seeded successfully"

# activities

# notifications

# invite_notifications

# transfer_notifications

# susu_notifications


# fees_and_commissions

# payment_methods

# payment_processors

# referral_contacts

# susus

# susu_invites

# susu_memberships


# transactions

# susu_transactions

# user_transactions





