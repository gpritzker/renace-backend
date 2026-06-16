require "active_support/core_ext/integer/time"

Rails.application.configure do
  Rails.application.routes.default_url_options[:host] = 'https://api.renace.com.ar'

  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local = false

  config.active_storage.service = :amazon
  config.active_job.queue_adapter = :sidekiq

  # HTTPS obligatorio + HSTS 1 año con subdomains y preload
  config.force_ssl = true
  config.ssl_options = {
    hsts: { subdomains: true, preload: true, expires: 1.year }
  }

  config.action_mailer.default_url_options = { host: ENV.fetch('BACKEND_HOST', 'api.renace.com.ar'), protocol: 'https' }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.smtp_settings = {
    address:              'smtp.resend.com',
    port:                 587,
    user_name:            'resend',
    password:             ENV['RESEND_API_KEY'],
    authentication:       :plain,
    enable_starttls_auto: true
  }
  config.action_mailer.default_options = {
    from: ENV.fetch('MAILER_FROM', 'Renace <noreply@renace.com.ar>')
  }

  config.log_level = :info
  config.logger = Logger.new($stdout)

  config.assets.compile = false
  config.assets.debug   = false
  config.assets.precompile += %w[application.js application.css]
end
