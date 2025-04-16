# app/controllers/admin/base_controller.rb
class Admin::BaseController < ApplicationController
  layout 'admin'

  before_action :authenticate_admin_user!

  private

  def current_admin_user
    @current_admin_user ||= User.find_by(id: session[:admin_user_id])
  end
  
  def authenticate_admin_user!
    unless current_admin_user&.admin?
      redirect_to new_admin_session_path, alert: 'Tenés que iniciar sesión como admin.'
    end
  end

  helper_method :current_admin_user
end