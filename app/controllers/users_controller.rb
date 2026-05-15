class UsersController < ApplicationController
  def new
    @user = User.new
    @role = params[:role] || 'student'
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

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :role, :education_level, :certificate_url, subject_ids: [])
  end
end
