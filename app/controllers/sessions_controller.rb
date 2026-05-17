class SessionsController < ApplicationController
  def new
  end

  def create
    # Handler especial de demonstração para facilitar apresentações e testes no Hackathon
    if (Rails.env.development? || Rails.env.test?) && params[:demo_admin] == "true"
      admin = User.find_or_initialize_by(email: "admin@aprendeai.com") do |u|
        u.name = "Administrador Demo"
        u.password = "senha123"
        u.role = :teacher
        u.education_level = :higher
        u.phone = "11999999999"
        u.cpf = "11122233344"
        u.certified = true
      end
      admin.admin = true
      admin.save(validate: false)

      # Cria perfis de demonstração flagrados se eles ainda não existirem
      if User.where(email: ["bobo@demo.com", "tonto@demo.com"]).empty?
        # Aluno com nome contendo letras repetidas e leetspeak
        u1 = User.new(
          name: "booooboooo",
          email: "bobo@demo.com",
          password: "password123",
          role: :student,
          phone: "11999999998",
          cpf: "11122233355",
          preferences: "Gosto de perturbar os professores e ser um 1d10t4."
        )
        u1.save(validate: false)

        # Professor com preferências contendo palavras de baixo calão e símbolos
        u2 = User.new(
          name: "Professor Tonto",
          email: "tonto@demo.com",
          password: "password123",
          role: :teacher,
          phone: "11999999997",
          cpf: "11122233366",
          experience: "Tenho experiência com aulas e sou um f.i.l.h.o-d.a_p.u.t.a completo.",
          certificate_url: "http://certificado.com",
          certified: true
        )
        u2.save(validate: false)
      end

      session[:user_id] = admin.id
      flash[:notice] = "Conectado como Administrador de Demonstração! O banco foi pré-populado com dados suspeitos."
      redirect_to admin_moderation_index_path
      return
    end

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
