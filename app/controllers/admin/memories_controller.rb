class Admin::MemoriesController < Admin::BaseController
    def index
      @memories = Memory.includes(:capsule).order(created_at: :desc)
    end

    def show
      @memory = Memory.find(params[:id])
    end

    def edit
      @memory = Memory.find(params[:id])
    end

    def update
      @memory = Memory.find(params[:id])
      if @memory.update(memory_params)
        redirect_to admin_memories_path, notice: 'Memory updated successfully'
      else
        render :edit
      end
    end

    def destroy
      @memory = Memory.find(params[:id])
      @memory.destroy
      redirect_to admin_memories_path, notice: 'Memory deleted successfully'
    end

    private

    def memory_params
      params.require(:memory).permit(:capsule_id, :content, :media_url, :memory_type, :file)
    end
end