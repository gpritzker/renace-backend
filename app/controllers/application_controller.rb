# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
    helper_method :current_admin
  
    def current_admin
      @current_admin ||= User.find_by(id: session[:admin_user_id]) if session[:admin_user_id]
    end
  
    def authenticate_admin!
      redirect_to new_admin_session_path, alert: 'Debés iniciar sesión como administrador.' unless current_admin&.admin?
    end
  end
  