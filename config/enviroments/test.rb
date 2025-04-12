require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.cache_classes = true
  config.eager_load = false

  config.consider_all_requests_local = true

  config.active_storage.service = :test

  config.active_job.queue_adapter = :inline

  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }

  config.log_level = :warn
end
