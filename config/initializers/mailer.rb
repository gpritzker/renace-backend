ActionMailer::Base.default_url_options = if Rails.env.production?
  { host: ENV.fetch('BACKEND_HOST', 'renace-backend.onrender.com'), protocol: 'https' }
else
  { host: 'localhost', port: 3000 }
end

if ENV['RESEND_API_KEY'].present?
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.perform_deliveries = true
  ActionMailer::Base.raise_delivery_errors = true
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
