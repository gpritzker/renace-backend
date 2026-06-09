class SendCapsuleNotificationWorker
  include Sidekiq::Worker
  sidekiq_options retry: 3

  def perform(capsule_id)
    capsule = Capsule.find_by(id: capsule_id)

    unless capsule
      logger.warn "[CapsuleMailer] Cápsula #{capsule_id} no encontrada, saltando."
      return
    end

    unless capsule.approved?
      logger.warn "[CapsuleMailer] Cápsula #{capsule_id} no aprobada, saltando."
      return
    end

    if capsule.recipient_email.blank?
      logger.warn "[CapsuleMailer] Cápsula #{capsule_id} sin destinatario, saltando."
      return
    end

    logger.info "[CapsuleMailer] Enviando cápsula #{capsule_id} a #{capsule.recipient_email}"
    CapsuleMailer.capsule_ready(capsule).deliver_now!
    logger.info "[CapsuleMailer] Mail enviado OK para cápsula #{capsule_id}"
  end
end
