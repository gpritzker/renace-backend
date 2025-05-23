# frozen_string_literal: true

module Api
  module V1
    class SessionsController < Devise::SessionsController
      respond_to :json
      skip_before_action :verify_authenticity_token

      private

      def respond_with(resource, _opts = {})
        token = request.env['warden-jwt_auth.token']

        render json: {
          status: { code: 200, message: 'Logged in successfully.' },
          data: UserSerializer.new(resource).as_json,
          token: token
        }, status: :ok
      end

      def respond_to_on_destroy
        if current_user
          render json: {
            status: 200,
            message: "Logged out successfully."
          }, status: :ok
        else
          render json: {
            status: 401,
            message: "Couldn't find an active session."
          }, status: :unauthorized
        end
      end
    end
  end
end