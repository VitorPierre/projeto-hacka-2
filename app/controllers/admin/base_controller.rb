class Admin::BaseController < ApplicationController
  before_action :require_login
  before_action :require_admin

  private

  def require_admin
    unless current_user&.admin?
      flash[:alert] = "Acesso restrito para administradores."
      redirect_to root_path and return
    end
  end
end
