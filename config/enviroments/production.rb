require "active_support/core_ext/integer/time"

Rails.application.configure do
  
  Rails.application.routes.default_url_options[:host] = 'https://api.renace.com.ar'

  config.assets.compile = false
  config.assets.precompile += %w( application.js application.css )
  config.cache_classes = true
  config.eager_load = true

  config.consider_all_requests_local = false

  config.active_storage.service = :amazon

  config.active_job.queue_adapter = :sidekiq

  config.action_mailer.default_url_options = { host: 'api.renace.com.ar' }

  config.log_level = :info
  config.logger = Logger.new($stdout)
  config.assets.debug = true
  config.force_ssl = true
end
