class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch('MAILER_FROM', 'Renace <noreply@renace.app>')
  layout 'mailer'
end
