module Api
  module V1
    class BillingController < ActionController::API
      before_action :authenticate_user!

      MP_API = 'https://api.mercadopago.com'

      def checkout
        plan_id = params[:plan_id]
        return render json: { error: 'plan_id requerido' }, status: :bad_request if plan_id.blank?

        response = HTTParty.post(
          "#{MP_API}/preapproval",
          headers: mp_headers,
          body: {
            preapproval_plan_id: plan_id,
            payer_email: current_user.email,
            back_url: "#{ENV['FRONTEND_URL']}/billing/success",
            external_reference: current_user.id.to_s
          }.to_json
        )

        if response.success?
          data = response.parsed_response
          current_user.update(mp_subscription_id: data['id'])
          render json: { url: data['init_point'] }
        else
          Rails.logger.error "MP checkout error: #{response.body}"
          render json: { error: 'Error al crear la suscripción en MercadoPago' }, status: :unprocessable_entity
        end
      end

      def cancel
        return render json: { error: 'Sin suscripción activa' }, status: :unprocessable_entity if current_user.mp_subscription_id.blank?

        response = HTTParty.put(
          "#{MP_API}/preapproval/#{current_user.mp_subscription_id}",
          headers: mp_headers,
          body: { status: 'cancelled' }.to_json
        )

        if response.success?
          current_user.update(premium: false, mp_subscription_id: nil)
          render json: { message: 'Suscripción cancelada' }
        else
          render json: { error: 'Error al cancelar' }, status: :unprocessable_entity
        end
      end

      private

      def mp_headers
        {
          'Authorization' => "Bearer #{ENV['MERCADOPAGO_ACCESS_TOKEN']}",
          'Content-Type' => 'application/json'
        }
      end
    end
  end
end
