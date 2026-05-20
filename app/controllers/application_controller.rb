class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.


  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_user, :logged_in?

  before_action :check_terms_acceptance

  private

  def current_user
    if session[:user_id]
      user = User.find_by(id: session[:user_id])
      if user && (user.suspended? || user.banned?)
        session[:user_id] = nil
        @current_user = nil
      else
        @current_user ||= user
      end
    end
  end

  def logged_in?
    !!current_user
  end

  def require_login
    unless logged_in?
      flash[:alert] = "Você precisa entrar para acessar esta página."
      redirect_to login_path
    end
  end

  def require_student
    unless current_user&.student?
      flash[:alert] = "Acesso restrito para alunos."
      redirect_to root_path
    end
  end

  def require_teacher
    unless current_user&.teacher?
      flash[:alert] = "Acesso restrito para professores."
      redirect_to root_path
    end
  end

  def check_terms_acceptance
    if logged_in? && !current_user.accepted_current_terms_and_privacy?
      return if allowed_actions_for_unaccepted_terms?

      flash[:alert] = "Atualizamos nossos Termos de Uso e Política de Privacidade. Por favor, leia e aceite os novos termos para continuar utilizando a plataforma."
      redirect_to accept_terms_path
    end
  end

  def allowed_actions_for_unaccepted_terms?
    (controller_name == 'home' && ['terms', 'privacy', 'accept_terms', 'submit_accept_terms'].include?(action_name)) ||
    (controller_name == 'sessions' && action_name == 'destroy')
  end
end
