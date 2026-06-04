module Api
  module V1
    class ConfirmationsController < Devise::ConfirmationsController
      skip_before_action :verify_authenticity_token

      # GET /confirmation?confirmation_token=xxx
      # Devise llama esto cuando el usuario hace click en el email
      def show
        self.resource = resource_class.confirm_by_token(params[:confirmation_token])

        if resource.errors.empty?
          redirect_to "#{ENV.fetch('FRONTEND_URL', 'https://renace.com.ar')}/login?confirmed=true",
                      allow_other_host: true
        else
          redirect_to "#{ENV.fetch('FRONTEND_URL', 'https://renace.com.ar')}/login?confirmed=false",
                      allow_other_host: true
        end
      end

      # POST /confirmation — reenviar email de confirmación
      def create
        self.resource = resource_class.send_confirmation_instructions(resource_params)
        if successfully_sent?(resource)
          render json: { message: 'Email de confirmación reenviado.' }, status: :ok
        else
          render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def resource_params
        params.require(:user).permit(:email)
      end
    end
  end
end
