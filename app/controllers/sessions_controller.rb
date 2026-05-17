class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:email])
    if user && user.authenticate(params[:password])
      if user.suspended?
        flash.now[:alert] = "Sua conta está suspensa temporariamente por violar os termos de uso."
        render :new, status: :unprocessable_entity
        return
      elsif user.banned?
        flash.now[:alert] = "Sua conta foi banida permanentemente por abuso e violação dos termos."
        render :new, status: :unprocessable_entity
        return
      end

      session[:user_id] = user.id
      flash[:notice] = "Bem-vindo(a) de volta!"
      redirect_to user.student? ? student_path(user) : teacher_path(user)
    else
      flash.now[:alert] = "E-mail ou senha inválidos."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session[:user_id] = nil
    flash[:notice] = "Desconectado com sucesso."
    redirect_to root_path
  end
end
