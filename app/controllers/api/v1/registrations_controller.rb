# frozen_string_literal: true

module Api
  module V1
    class RegistrationsController < Devise::RegistrationsController
      respond_to :json
      skip_before_action :verify_authenticity_token

      before_action :skip_confirmation_in_development, only: :create

      private

      def skip_confirmation_in_development
        resource_class.skip_confirmation! if Rails.env.development?
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