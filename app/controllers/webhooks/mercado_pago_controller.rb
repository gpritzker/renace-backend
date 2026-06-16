module Webhooks
  class MercadoPagoController < ActionController::API
    before_action :verify_signature

    MP_API = 'https://api.mercadopago.com'

    def receive
      topic = params[:type] || params[:topic]

      case topic
      when 'subscription_preapproval'
        preapproval_id = params.dig(:data, :id) || params[:id]
        handle_subscription(preapproval_id) if preapproval_id.present?
      end

      head :ok
    end

    private

    # MercadoPago firma los webhooks con HMAC-SHA256
    # Header: x-signature → "ts=...,v1=..."
    def verify_signature
      secret = ENV['MERCADOPAGO_WEBHOOK_SECRET']
      return if secret.blank? && !Rails.env.production?

      signature_header = request.headers['x-signature'].to_s
      request_id       = request.headers['x-request-id'].to_s

      ts  = signature_header[/ts=([^,]+)/, 1]
      v1  = signature_header[/v1=([^,]+)/, 1]

      if ts.blank? || v1.blank?
        render json: { error: 'Firma inválida' }, status: :unauthorized
        return
      end

      data_id = params.dig(:data, :id).to_s
      manifest = "id:#{data_id};request-id:#{request_id};ts:#{ts};"

      expected = OpenSSL::HMAC.hexdigest('SHA256', secret, manifest)

      unless ActiveSupport::SecurityUtils.secure_compare(expected, v1)
        Rails.logger.warn "MercadoPago webhook signature mismatch from #{request.remote_ip}"
        render json: { error: 'Firma inválida' }, status: :unauthorized
      end
    end

    def handle_subscription(preapproval_id)
      response = HTTParty.get(
        "#{MP_API}/preapproval/#{preapproval_id}",
        headers: { 'Authorization' => "Bearer #{ENV['MERCADOPAGO_ACCESS_TOKEN']}" }
      )
      return unless response.success?

      data = response.parsed_response
      user = User.find_by(id: data['external_reference'])
      user ||= User.find_by(email: data.dig('payer', 'email'))
      return unless user

      case data['status']
      when 'authorized'
        user.update(premium: true, mp_subscription_id: preapproval_id)
        user.capsules.where(approved: false).each(&:approve!)
        Rails.logger.info "MercadoPago: usuario #{user.id} activado como premium"
      when 'cancelled', 'paused'
        user.update(premium: false, mp_subscription_id: nil)
        Rails.logger.info "MercadoPago: usuario #{user.id} desactivado de premium"
      end
    end
  end
end
