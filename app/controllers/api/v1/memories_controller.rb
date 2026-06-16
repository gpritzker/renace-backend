module Api
  module V1
    class MemoriesController < ActionController::API
      before_action :authenticate_user!
      before_action :set_owned_capsule, only: [:create]
      before_action :set_owned_memory, only: [:show, :update, :destroy]

      def index
        memories = Memory.joins(:capsule).where(capsules: { user_id: current_user.id })
        memories = memories.where(capsule_id: params[:capsule_id]) if params[:capsule_id].present?
        render json: memories
      end

      def create
        memory = @capsule.memories.build(memory_params)
        if memory.save
          render json: memory, status: :created
        else
          render json: { errors: memory.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @memory.update(memory_params)
          render json: @memory
        else
          render json: { errors: @memory.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def show
        render json: @memory
      end

      def destroy
        @memory.destroy
        render json: { message: "Memory deleted" }
      end

      private

      def set_owned_capsule
        @capsule = current_user.capsules.find_by(id: params.dig(:memory, :capsule_id))
        render json: { error: "Capsule not found" }, status: :not_found unless @capsule
      end

      def set_owned_memory
        @memory = Memory.joins(:capsule).where(capsules: { user_id: current_user.id }).find_by(id: params[:id])
        render json: { error: "Memory not found" }, status: :not_found unless @memory
      end

      def memory_params
        params.require(:memory).permit(:content, :memory_type, :file)
      end
    end
  end
end
