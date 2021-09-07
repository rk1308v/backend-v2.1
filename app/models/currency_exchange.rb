class CurrencyExchange < ApplicationRecord
    has_paper_trail
    
    require 'uri'
    require 'csv'
    require 'roo'

    validates :currency_from, presence: true
    validates :currency_to, presence: true

    def self.download_exchange_rates
        uri = URI.parse("#{ENV['APILAYER_HOST']}#{ENV['APILAYER_LIVE_URI']}?access_key=#{ENV['APILAYER_ACCESS_KEY']}")
        response = Net::HTTP.get_response(uri)
        json_data = JSON.parse(response.body)
        if json_data["success"] == true
            timestamp = json_data["timestamp"]
            effective_date = Time.at(timestamp).to_datetime
            quotes = json_data["quotes"]
            quotes.each do |quote|
                quote_data = quote[0].scan /.{3}/
                currency_from = quote_data[0]
                currency_to = quote_data[1]
                currency_exchange = CurrencyExchange.where('currency_from = ? AND currency_to = ?', currency_from, currency_to).last
                effective_exchg_rate = 0
                if currency_exchange.blank?
                    CurrencyExchange.create(value: BigDecimal(quote[1].to_s), effective_date: effective_date, active: true, currency_from: currency_from, currency_to: currency_to)
                else
                    currency_exchange.update(value: BigDecimal(quote[1].to_s), effective_date: effective_date)
                end
            end
        end
        self.setup_effective_exchange_rate
    end

    def self.setup_effective_exchange_rate
        xlsx = Roo::Spreadsheet.open('public/csv-exchange-rate/exchange-rate.xlsx')
        xlsx.each_row_streaming do |row|
            if row[0].value == 'USD'
                currency_from = row[0].value.to_s
                currency_to = row[1].value.to_s
                money_gram = row[2].value
                western_union = row[3].value
                
                exchg = CurrencyExchange.find_by(currency_from: currency_from, currency_to: currency_to)
                if exchg
                    mid_market_rate = exchg.value
                    avg = (money_gram + western_union) / 2.0
                    effective_rate = avg > mid_market_rate ? mid_market_rate : avg
                    exchg.update(money_gram_rate: money_gram, western_union_rate: western_union, effective_exchange_rate: effective_rate)
                end
            end
        end

        # csv_text = File.read(Rails.root.join('public', 'csv-exchange-rate', 'exchange-rate.csv'))
        # csv = CSV.parse(csv_text, :headers => true)
        # csv.each do |row|
        #     currency_from = row[0].to_s
        #     currency_to = row[1].to_s
        #     money_gram = row[2].to_f
        #     western_union = row[3].to_f
        #     exchg = CurrencyExchange.find_by(currency_from: currency_from, currency_to: currency_to)
        #     if exchg
        #         mid_market_rate = exchg.value
        #         avg = (money_gram + western_union) / 2.0
        #         effective_rate = avg > mid_market_rate ? mid_market_rate : avg
        #         exchg.update(money_gram_rate: money_gram, western_union_rate: western_union, effective_exchange_rate: effective_rate)
        #     end
        # end
    end

    def self.get_exchange_rate(currency_from, currency_to)
        currency_exchange = CurrencyExchange.where('currency_from = ? AND currency_to = ?', currency_from, currency_to).last
        if currency_exchange.blank?
            return 0
        else
            currency_exchange.value
        end
    end
end
