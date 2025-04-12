require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.cache_classes = false
  config.eager_load = false

  config.consider_all_requests_local = true

  config.active_storage.service = :local

  config.active_job.queue_adapter = :sidekiq

  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }

  config.active_support.deprecation = :log
  config.active_record.migration_error = :page_load
  config.active_record.verbose_query_logs = true

  config.logger = Logger.new($stdout)
  config.log_level = :debug

  config.action_mailer.delivery_method = :smtp

  config.action_mailer.smtp_settings = {
    address:              "smtp.gmail.com", # o el que uses
    port:                 587,
    domain:               "renacer.com.ar",
    user_name:            ENV['MAIL_USERNAME'],
    password:             ENV['MAIL_PASSWORD'],
    authentication:       :plain,
    enable_starttls_auto: true
  }
end
