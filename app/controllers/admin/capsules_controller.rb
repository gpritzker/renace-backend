class Admin::CapsulesController < Admin::BaseController
    def index
      @capsules = Capsule.includes(:user).order(created_at: :desc)
    end
  
    def show
      @capsule = Capsule.find(params[:id])
    end
  
    def edit
      @capsule = Capsule.find(params[:id])
    end
  
    def update
      @capsule = Capsule.find(params[:id])
      if @capsule.update(capsule_params)
        redirect_to admin_capsules_path, notice: 'Capsule updated successfully'
      else
        render :index, alert: 'Could not update capsule'
      end
    end
  
    def approve
      @capsule = Capsule.find(params[:id])
      @capsule.approve!
      redirect_to admin_capsule_path(@capsule), notice: 'Cápsula aprobada.'
    end

    def disapprove
      @capsule = Capsule.find(params[:id])
      @capsule.disapprove!
      redirect_to admin_capsule_path(@capsule), notice: 'Cápsula desaprobada.'
    end

    def destroy
      @capsule = Capsule.find(params[:id])
      @capsule.destroy
      redirect_to admin_capsules_path, notice: 'Capsule deleted successfully'
    end
  
    private
  
    def capsule_params
      params.require(:capsule).permit(:title, :description, :approved, :open_at)
    end
  end