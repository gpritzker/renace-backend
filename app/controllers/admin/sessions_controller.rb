# app/controllers/admin/sessions_controller.rb
class Admin::SessionsController <  Admin::BaseController
   layout false, only: [:new]
   skip_before_action :authenticate_admin_user!

  
    def new; end
  
    def create
      user = User.find_by(email: params[:email])
      if user&.valid_password?(params[:password]) && user.admin?
        session[:admin_user_id] = user.id
        #sign_in(user)
        redirect_to admin_root_path, notice: 'Sesión iniciada correctamente.'
      else
        flash[:alert] = 'Credenciales inválidas o no sos admin.'
        redirect_to new_admin_session_path
      end
    end
  
    def destroy
      session[:admin_user_id] = nil
      redirect_to new_admin_session_path, notice: 'Sesión cerrada correctamente.'
    end
  end
  