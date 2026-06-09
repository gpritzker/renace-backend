class Admin::UsersController < Admin::BaseController
  def index
    @users = User.order(created_at: :desc)
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to admin_user_path(@user), notice: 'Usuario actualizado correctamente.'
    else
      render :edit
    end
  end

  def confirm
    @user = User.find(params[:id])
    @user.confirm
    @user.update_column(:approved_at, Time.current)
    redirect_to admin_user_path(@user), notice: 'Cuenta confirmada correctamente.'
  end

  def toggle_premium
    @user = User.find(params[:id])
    if @user.premium?
      @user.update(premium: false, mp_subscription_id: nil)
      notice = "Premium desactivado para #{@user.email}"
    else
      @user.update(premium: true, approved_at: @user.approved_at || Time.current)
      @user.capsules.where(approved: false).each(&:approve!)
      notice = "Premium activado para #{@user.email}"
    end
    redirect_to admin_user_path(@user), notice: notice
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to admin_users_path, notice: 'Usuario eliminado correctamente.'
  end

  private

  def user_params
    params.require(:user).permit(:email, :admin)
  end
end
