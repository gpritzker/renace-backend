module Api
  module V1
    class ProfileController < ActionController::API
      before_action :authenticate_user!

      def show
        render json: { data: UserSerializer.new(current_user) }, status: :ok
      end

      def update
        if current_user.update(profile_params)
          render json: { data: UserSerializer.new(current_user) }, status: :ok
        else
          render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def profile_params
        params.require(:user).permit(:first_name, :last_name, :dni, :birth_date, :phone)
      end
    end
  end
end
