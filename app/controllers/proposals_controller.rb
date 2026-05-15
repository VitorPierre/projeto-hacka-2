class ProposalsController < ApplicationController
  before_action :require_login
  before_action :set_proposal, only: [:show, :update, :accept, :reject, :close]

  def new
    if current_user.student?
      @teacher = User.certified_teachers.find(params[:teacher_id])
      @student = current_user
    elsif current_user.teacher?
      @student = User.student.find(params[:student_id])
      @teacher = current_user
    else
      redirect_to root_path, alert: "Acesso não permitido."
      return
    end
    @proposal = Proposal.new
  end

  def create
    if current_user.student?
      @proposal = Proposal.new(proposal_params)
      @proposal.student = current_user
      @proposal.teacher_id = proposal_params[:teacher_id]
    elsif current_user.teacher?
      @proposal = Proposal.new(proposal_params)
      @proposal.teacher = current_user
      @proposal.student_id = proposal_params[:student_id]
    else
      redirect_to root_path, alert: "Acesso não permitido."
      return
    end
    @proposal.status = :pending
    
    if @proposal.save
      flash[:notice] = "Proposta enviada com sucesso! Aguarde a resposta."
      redirect_to proposal_path(@proposal)
    else
      # Reload counterpart for re-rendering the form
      if current_user.student?
        @teacher = User.find_by(id: proposal_params[:teacher_id])
        @student = current_user
      else
        @student = User.find_by(id: proposal_params[:student_id])
        @teacher = current_user
      end
      flash.now[:alert] = "Não foi possível enviar a proposta: " + @proposal.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @messages = @proposal.messages.includes(:user).order(created_at: :asc)
    @message = Message.new
  end

  def accept
    if current_user.teacher? && @proposal.pending?
      @proposal.update(status: :accepted)
      flash[:notice] = "Proposta aceita com sucesso!"
    else
      flash[:alert] = "Ação não permitida."
    end
    redirect_to proposal_path(@proposal)
  end

  def reject
    if current_user.teacher? && @proposal.pending?
      @proposal.update(status: :rejected)
      flash[:notice] = "Proposta recusada."
    else
      flash[:alert] = "Ação não permitida."
    end
    redirect_to proposal_path(@proposal)
  end

  def close
    if @proposal.accepted?
      @proposal.update(status: :closed)
      flash[:notice] = "Proposta fechada."
    else
      flash[:alert] = "Ação não permitida."
    end
    redirect_to proposal_path(@proposal)
  end

  def update
    new_status = params[:status]
    if current_user.student? && %w[accepted rejected].include?(new_status)
      flash[:alert] = "Aluno não pode aceitar ou recusar propostas."
      redirect_to student_path(current_user)
      return
    end

    if @proposal.update(status: new_status)
      flash[:notice] = "Status da proposta atualizado!"
    else
      flash[:alert] = @proposal.errors.full_messages.to_sentence
    end
    
    redirect_to proposal_path(@proposal)
  end

  private

  def set_proposal
    @proposal = Proposal.where("student_id = ? OR teacher_id = ?", current_user.id, current_user.id).find_by(id: params[:id])
    unless @proposal
      flash[:alert] = "Proposta não encontrada ou acesso negado."
      redirect_to root_path
    end
  end

  def proposal_params
    params.require(:proposal).permit(:teacher_id, :student_id, :subject_id, :price)
  end
end
