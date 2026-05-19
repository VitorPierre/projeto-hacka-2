class UsersController < ApplicationController
  before_action :require_login, only: [:edit, :update]
  def new
    @user = User.new
    @role = params[:role] || "student"
  end

  def create
    @user = User.new(user_params)
    @user.certified = false if @user.teacher?

    if @user.save
      session[:user_id] = @user.id
      flash[:notice] = "Conta criada com sucesso!"
      redirect_to @user.student? ? student_path(@user) : teacher_path(@user)
    else
      @role = @user.role
      render :new, status: :unprocessable_entity
    end
  end

  # AJAX endpoint para checagem em tempo real de termos impróprios
  def check_moderation
    text = params[:text].to_s
    is_inappropriate = ModerationService.inappropriate?(text)
    render json: { inappropriate: is_inappropriate }
  end

  def edit
    @user = User.find(params[:id])
    if @user != current_user
      flash[:alert] = "Acesso não autorizado."
      redirect_to root_path
    end
  end

  def update
    @user = User.find(params[:id])
    if @user != current_user
      flash[:alert] = "Acesso não autorizado."
      redirect_to root_path
      return
    end

    if @user.update(user_params)
      flash[:notice] = "Perfil atualizado com sucesso!"
      redirect_to @user.student? ? student_path(@user) : teacher_path(@user)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    p = params.require(:user).permit(:name, :email, :password, :role, :education_level, :certificate_url, :presentation_video_url, :preferences, :experience, :avatar, :phone, :cpf, :availability, subject_ids: [])
    p[:cpf] = p[:cpf].gsub(/\D/, "") if p[:cpf].present?
    p[:phone] = p[:phone].gsub(/\D/, "") if p[:phone].present?
    p
  end
end
