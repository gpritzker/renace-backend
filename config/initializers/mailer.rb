if Rails.env.production? && ENV['RESEND_API_KEY'].present?
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.perform_deliveries = true
  ActionMailer::Base.raise_delivery_errors = false
  ActionMailer::Base.smtp_settings = {
    address:              'smtp.resend.com',
    port:                 587,
    user_name:            'resend',
    password:             ENV['RESEND_API_KEY'],
    authentication:       :plain,
    enable_starttls_auto: true
  }
  ActionMailer::Base.default from: ENV.fetch('MAILER_FROM', 'Renace <noreply@renace.com.ar>')
end
