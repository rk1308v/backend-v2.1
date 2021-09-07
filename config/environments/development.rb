require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded any time
  # it changes. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true
  config.force_ssl = false

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp', 'caching-dev.txt').exist?
    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  ## Set this to true and configure the email server for immediate delivery to raise delivery errors.
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_caching = false
  config.action_mailer.default_url_options = {host: ENV['APP_DOMAIN']}
  config.action_mailer.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = {            
    :address              => ENV['SMTP_HOST'], 
    :port                 => ENV['SMTP_PORT'].to_i,                 
    :user_name            => ENV['SMTP_USERNAME'],
    :password             => ENV['SMTP_PASSWORD'],
    :domain               => ENV['DOMAIN'],         
    :authentication       => :login,
    :ssl                  => true,
    :tls                  => true,
    :enable_starttls_auto => true
  }

  # Root URL configuration
  config.after_initialize do
    Rails.application.routes.default_url_options[:host] = ENV['WEB_DOMAIN']
  end

  #config.action_controller.default_url_options = { :host => "localhost", port: 3000 }

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true


  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  # Uncomment if you wish to allow Action Cable access from any origin.
  # config.action_cable.disable_request_forgery_protection = true

  # AWS S3 configuration variables to store Paperclip image files
  config.paperclip_defaults = {
    storage: :s3,
    s3_region: ENV.fetch('AWS_REGION'),
    s3_host_name: "s3-#{ENV['AWS_REGION']}.amazonaws.com",
    s3_permissions: :public,
    s3_credentials: {
      bucket: ENV.fetch('S3_BUCKET_NAME'),
      access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID'),
      secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY'),
      #s3_host_name: "s3-#{ENV['AWS_REGION']}.amazonaws.com",
      #s3_region: ENV.fetch('AWS_REGION'),
    }
  }
end
