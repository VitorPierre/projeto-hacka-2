class TeachersController < ApplicationController
  before_action :check_teacher_access

  def index
    base_teachers = User.certified_teachers.includes(:subjects)
    if params[:subject_id].present?
      base_teachers = base_teachers.joins(:subjects).where(subjects: { id: params[:subject_id] }).distinct
    end

    @teachers = base_teachers.sort_by do |teacher|
      [-(teacher.average_rating || 0.0), -teacher.ratings_count]
    end
  end

  def show
    @teacher = User.teacher.find(params[:id])
    if @teacher.banned? && !current_user&.admin?
      raise ActiveRecord::RecordNotFound
    end
    if current_user == @teacher
      @proposals = current_user.received_proposals.includes(:student, :subject).order(created_at: :desc)
      @scheduled_proposals = current_user.proposals_as_teacher
                                          .where.not(scheduled_at: nil)
                                          .where(finished_at: nil)
                                          .includes(:student, :subject)
                                          .order(scheduled_at: :asc)
    end
  end

  private

  def check_teacher_access
    if current_user&.teacher? && (action_name == 'index' || params[:id].to_s != current_user.id.to_s)
      redirect_to students_path, alert: "Você só tem acesso a alunos ou ao seu painel."
    end
  end
end
