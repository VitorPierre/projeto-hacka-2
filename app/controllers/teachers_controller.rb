class TeachersController < ApplicationController
  before_action :check_teacher_access

  def index
    @teachers = User.certified_teachers.includes(:subjects)
  end

  def show
    @teacher = User.teacher.find(params[:id])
    if current_user == @teacher
      @proposals = current_user.received_proposals.includes(:student, :subject).order(created_at: :desc)
    end
  end

  def update_subjects
    @teacher = current_user
    @teacher.subject_ids = params[:subject_ids] || []
    if @teacher.save
      redirect_to teacher_path(@teacher), notice: "Especialidades atualizadas com sucesso!"
    else
      redirect_to teacher_path(@teacher), alert: "Erro aoatualizar as especialidades: "
    end
  end

  private

  def check_teacher_access
    if current_user&.teacher? && (action_name == 'index' || params[:id].to_s != current_user.id.to_s)
      redirect_to students_path, alert: "Você só tem acesso a alunos ou ao seu painel."
    end
  end
end
