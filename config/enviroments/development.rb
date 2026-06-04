require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.cache_classes = false
  config.eager_load = false

  config.consider_all_requests_local = true

  config.active_storage.service = :amazon
  config.action_controller.default_url_options = { host: 'http://localhost:3000' }
  Rails.application.routes.default_url_options[:host] = 'http://localhost:3000'

  config.assets.debug = true

  config.active_job.queue_adapter = :sidekiq

  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }

  config.active_support.deprecation = :log
  config.active_record.migration_error = :page_load
  config.active_record.verbose_query_logs = true

  config.logger = Logger.new($stdout)
  config.log_level = :debug

  if ENV['RESEND_API_KEY'].present?
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.perform_deliveries = true
    config.action_mailer.smtp_settings = {
      address:              'smtp.resend.com',
      port:                 587,
      user_name:            'resend',
      password:             ENV['RESEND_API_KEY'],
      authentication:       :plain,
      enable_starttls_auto: true
    }
  else
    config.action_mailer.delivery_method = :letter_opener
    config.action_mailer.perform_deliveries = true
  end
end
