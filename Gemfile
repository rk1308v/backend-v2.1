source 'https://rubygems.org'
ruby '2.6.5' #"2.5.1"

gem 'rails', '~> 6.1.4'
gem 'pg'
# gem 'mysql2', '>= 0.4.4', '< 0.6.0'
gem 'puma', '~> 3.0'
gem 'execjs'
gem 'therubyracer'
gem 'thin'
gem 'roo'
gem 'fcm'

group :development, :staging, :test do
    gem 'rspec-rails', '~> 3.1.0'
    gem 'rswag-specs'
    gem 'factory_bot'
    gem 'byebug', platform: :mri
    gem 'pry-rails'
    gem 'rubyzip', '2.3.0'
end

group :development, :staging do
    gem 'listen', '~> 3.0.5'
    gem 'spring'
    gem 'spring-watcher-listen', '~> 2.0.0'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem 'habtm_generator', :group => :development, :git => 'https://github.com/krishnakumar03/ruby-habtm-generator.git'
gem 'kaminari'
gem 'paperclip', '~> 5.0.0'
gem 'aws-sdk', '~> 2.3.0'
gem 'webmock', '~> 2.0'
# gem 'rails_12factor', group: :staging
gem 'apipie-rails'
gem 'twilio-ruby'
gem "figaro" # Reads a config/application.yml file and sets environment variables before anything else is configured in the Rails application.
gem 'phone'
gem 'whenever', require: false
gem 'stripe'
gem 'paper_trail'
gem 'geocoder'
gem 'rmagick'

group :test do
    gem 'shoulda-matchers'
    gem 'database_cleaner'
    gem 'faker'
end

group :development do
    gem 'capistrano'
    gem 'capistrano-rails'
    gem 'capistrano-bundler'
    gem 'capistrano-rvm'
    gem 'capistrano-passenger'
end

gem 'devise', git: 'https://github.com/plataformatec/devise.git'
gem 'countries'
gem 'money'
gem 'sidekiq'
gem 'redis'
gem 'redis-namespace'
gem 'rack-cors'
gem 'rswag-api'
gem 'rswag-ui'