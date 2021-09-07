set :output, '/var/www/money_api/current/log/cron.log'
every 1.hours do
    runner "CurrencyExchange.download_exchange_rates"
end