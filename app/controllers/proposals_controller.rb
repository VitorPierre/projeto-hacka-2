class ProposalsController < ApplicationController
  before_action :require_login
  before_action :require_student, only: [:new, :create]
  before_action :set_proposal, only: [:show, :update, :accept, :reject, :close]

  def new
    @teacher = User.certified_teachers.find(params[:teacher_id])
    @proposal = Proposal.new
  end

  def create
    @proposal = current_user.sent_proposals.build(proposal_params)
    @proposal.status = :pending
    
    if @proposal.save
      flash[:notice] = "Proposta enviada com sucesso! Aguarde a resposta."
      redirect_to proposal_path(@proposal)
    else
      @teacher = User.find(proposal_params[:teacher_id])
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
    params.require(:proposal).permit(:teacher_id, :subject_id, :price)
  end
end
