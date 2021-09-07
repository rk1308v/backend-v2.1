desc "Update currency exchanges"
task update_currency_exchanges: :environment do
    puts "Updating currency exchanges"
    CurrencyExchange.download_exchange_rates
    puts "Curreny exchanges updated"
end