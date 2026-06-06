# frozen_string_literal: true

module Api
  module V1
    class RegistrationsController < Devise::RegistrationsController
      respond_to :json
      skip_before_action :verify_authenticity_token

      before_action :configure_sign_up_params, only: :create

      def build_resource(hash = {})
        super
        resource.skip_confirmation! if Rails.env.development?
      end

      private

      def configure_sign_up_params
        devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :dni, :birth_date, :phone])
      end

      def respond_with(resource, _opts = {})
        if resource.persisted?
          render json: {
            status: { code: 200, message: 'Cuenta creada correctamente.' },
            data: resource
          }, status: :ok
        else
          render json: {
            status: 422,
            errors: resource.errors.full_messages
          }, status: :unprocessable_entity
        end
      end
    end
  end
end