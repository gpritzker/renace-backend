module Api
  module V1
    class MemoriesController < ActionController::API
      before_action :authenticate_user!

      def index
        memories = Memory.joins(:capsule).where(capsules: { user_id: current_user.id })
        render json: memories
      end

      def create
        memory = Memory.new(memory_params)
        if memory.save
          render json: memory, status: :created
        else
          render json: { errors: memory.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        memory = Memory.find(params[:id])
        if memory.capsule.user_id == current_user.id && memory.update(memory_params)
          render json: memory
        else
          render json: { errors: memory.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def memory_params
        params.require(:memory).permit(:capsule_id, :content, :media_url, :memory_type, :file)
      end
    end
  end
end