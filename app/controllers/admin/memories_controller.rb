class Admin::MemoriesController < Admin::BaseController
    def index
      @memories = Memory.includes(:capsule).order(created_at: :desc)
    end
end