# frozen_string_literal: true

module Api
  module V1
    class CapsulesController < ApplicationController
      before_action :authenticate_user!

      def index
        render json: current_user.capsules
      end

      def show
        capsule = current_user.capsules.find(params[:id])
        render json: capsule
      end

      def create
        capsule = current_user.capsules.build(capsule_params)
        if capsule.save
          render json: capsule, status: :created
        else
          render json: { errors: capsule.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def capsule_params
        params.require(:capsule).permit(:title, :description, :open_at)
      end
    end
  end
end