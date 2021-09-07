Sidekiq.configure_server do |config|
    config.redis = { url: Rails.env == 'staging' ? 'redis://redistogo:b5a9631594ff480d9747f9d6929f7f23@crestfish.redistogo.com:9219/' : 'redis:localhost:6379' }
    config.average_scheduled_poll_interval = 10
end
  
Sidekiq.configure_client do |config|
    config.redis = { url: Rails.env == 'staging' ? 'redis://redistogo:b5a9631594ff480d9747f9d6929f7f23@crestfish.redistogo.com:9219/' : 'redis:localhost:6379' }
    config.average_scheduled_poll_interval = 10
end