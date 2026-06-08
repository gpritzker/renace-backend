class SendCapsuleNotificationWorker
  include Sidekiq::Worker
  sidekiq_options retry: 3

  def perform(capsule_id)
    capsule = Capsule.find_by(id: capsule_id)
    return unless capsule
    return unless capsule.approved?
    return if capsule.recipient_email.blank?

    CapsuleMailer.capsule_ready(capsule).deliver_now
  end
end
