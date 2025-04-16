class Admin::CapsulesController < Admin::BaseController
    def index
      @capsules = Capsule.includes(:user).order(created_at: :desc)
    end
  
    def update
      @capsule = Capsule.find(params[:id])
      if @capsule.update(capsule_params)
        redirect_to admin_capsules_path, notice: 'Capsule updated successfully'
      else
        render :index, alert: 'Could not update capsule'
      end
    end
  
    private
  
    def capsule_params
      params.require(:capsule).permit(:approved)
    end
  end