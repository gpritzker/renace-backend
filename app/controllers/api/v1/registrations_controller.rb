# frozen_string_literal: true

module Api
  module V1
    class RegistrationsController < Devise::RegistrationsController
      respond_to :json
      skip_before_action :verify_authenticity_token

      def create
        super do |resource|
          # Auto-confirmar si el usuario fue creado exitosamente
          resource.confirm! if resource.persisted? && !resource.confirmed?
        end
      end

      private

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