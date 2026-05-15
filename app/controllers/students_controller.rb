class StudentsController < ApplicationController
  before_action :check_student_access

  def index
    @students = User.student.includes(:subjects)
  end

  def show
    @student = User.student.find(params[:id])
    if current_user == @student
      @proposals = current_user.sent_proposals.includes(:teacher, :subject).order(created_at: :desc)
    end
  end

  private

  def check_student_access
    if current_user&.student? && (action_name == 'index' || params[:id].to_s != current_user.id.to_s)
      redirect_to teachers_path, alert: "Você só tem acesso a professores ou ao seu painel."
    end
  end
end
