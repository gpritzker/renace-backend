# frozen_string_literal: true

module Api
  module V1
    class CapsulesController < ActionController::API
      before_action :authenticate_user!
      respond_to :json

      def index
        render json: current_user.capsules
      end

      def show
        capsule = current_user.capsules.find_by(id: params[:id])
        if capsule
          render json: capsule
        else
          render json: { error: "Capsule not found" }, status: :not_found
        end
      end

      def create
        capsule = current_user.capsules.build(capsule_params)
        if capsule.save
          capsule.approve! if current_user.capsules.count == 1 || current_user.premium?
          schedule_notification(capsule)
          render json: capsule, status: :created
        else
          render json: { errors: capsule.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        capsule = current_user.capsules.find(params[:id])
        if capsule.update(capsule_params)
          schedule_notification(capsule)
          render json: capsule
        else
          render json: { errors: capsule.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        capsule = current_user.capsules.find_by(id: params[:id])
        if capsule
          capsule.destroy
          render json: { message: "Capsule deleted" }
        else
          render json: { error: "Capsule not found" }, status: :not_found
        end
      end

      private

      def capsule_params
        params.require(:capsule).permit(:title, :description, :open_at, :recipient_email)
      end

      def schedule_notification(capsule)
        return if capsule.open_at.blank? || capsule.recipient_email.blank?
        return if capsule.open_at <= Time.current
        SendCapsuleNotificationWorker.perform_at(capsule.open_at, capsule.id)
      end
    end
  end
end