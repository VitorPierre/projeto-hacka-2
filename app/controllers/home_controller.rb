class HomeController < ApplicationController
  def index
    if logged_in?
      redirect_to current_user.student? ? student_path(current_user) : teacher_path(current_user)
      return
    end
    
    @teachers = User.teacher.public_view.includes(:subjects).limit(3)
    @students = User.student.public_view.includes(:subjects).limit(3)
  end

  def terms
  end

  def privacy
  end

  def accept_terms
  end

  def submit_accept_terms
    if params[:terms_acceptance] == "1"
      if current_user.update(
        terms_accepted_version: User::CURRENT_TERMS_VERSION,
        privacy_accepted_version: User::CURRENT_PRIVACY_VERSION,
        terms_accepted_at: Time.current
      )
        flash[:notice] = "Termos aceitos com sucesso! Bem-vindo de volta."
        redirect_to current_user.student? ? student_path(current_user) : teacher_path(current_user)
      else
        flash.now[:alert] = "Não foi possível registrar o seu aceite. Tente novamente."
        render :accept_terms, status: :unprocessable_entity
      end
    else
      flash.now[:alert] = "Você precisa marcar a caixa indicando que leu e aceitou os novos termos para continuar."
      render :accept_terms, status: :unprocessable_entity
    end
  end
end
