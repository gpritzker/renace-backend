module Webhooks
  class MercadoPagoController < ActionController::API

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

    def handle_subscription(preapproval_id)
      response = HTTParty.get(
        "#{MP_API}/preapproval/#{preapproval_id}",
        headers: { 'Authorization' => "Bearer #{ENV['MERCADOPAGO_ACCESS_TOKEN']}" }
      )
      return unless response.success?

      data = response.parsed_response
      user = User.find_by(id: data['external_reference'])
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
