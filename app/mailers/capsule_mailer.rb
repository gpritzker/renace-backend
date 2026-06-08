class CapsuleMailer < ApplicationMailer
  def capsule_ready(capsule)
    @capsule = capsule
    @owner = capsule.user
    @url = "#{ENV.fetch('FRONTEND_URL', 'http://localhost:3000')}/capsule/#{capsule.id}"
    @owner_name = [@owner.first_name, @owner.last_name].compact.join(' ').presence || @owner.email.split('@').first

    mail(
      to: capsule.recipient_email,
      subject: "#{@owner_name} te dejó una cápsula en Renace"
    )
  end
end
