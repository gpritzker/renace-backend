module Api
  module V1
    class PasswordsController < Devise::PasswordsController
      respond_to :json
      skip_before_action :verify_authenticity_token

      def create
        self.resource = resource_class.send_reset_password_instructions(resource_params)
        if successfully_sent?(resource)
          render json: { message: 'Se enviaron las instrucciones al email indicado.' }, status: :ok
        else
          render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
        end
      rescue => e
        Rails.logger.error "[PasswordsController] Mail error: #{e.class} - #{e.message}"
        # Respondemos OK igual para no revelar si el email existe
        render json: { message: 'Si el email está registrado, vas a recibir las instrucciones.' }, status: :ok
      end

      def update
        self.resource = resource_class.reset_password_by_token(resource_params)
        if resource.errors.empty?
          # Si llegó el email de reset, el email está verificado — confirmamos la cuenta
          resource.confirm! if resource.respond_to?(:confirmed?) && !resource.confirmed?
          render json: { message: 'Contraseña actualizada correctamente.' }, status: :ok
        else
          render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def resource_params
        params.require(:user).permit(:email, :password, :password_confirmation, :reset_password_token)
      end
    end
  end
end
