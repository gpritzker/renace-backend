# frozen_string_literal: true

module Api
  module V1
    class MemoriesController < ApplicationController
      before_action :authenticate_user!

      def index
        render json: Memory.all
      end

      def create
        memory = Memory.new(memory_params)
        if memory.save
          render json: memory, status: :created
        else
          render json: { errors: memory.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def memory_params
        params.require(:memory).permit(:capsule_id, :content, :media_url, :memory_type)
      end
      
    end
  end
end