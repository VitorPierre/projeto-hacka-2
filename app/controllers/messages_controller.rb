class MessagesController < ApplicationController
  before_action :require_login

  def create
    @proposal = Proposal.where("student_id = ? OR teacher_id = ?", current_user.id, current_user.id).find_by(id: params[:proposal_id])
    
    unless @proposal
      flash[:alert] = "Proposta não encontrada ou acesso negado."
      redirect_to root_path
      return
    end

    @message = @proposal.messages.build(message_params)
    @message.user = current_user

    if @message.activity? && !current_user.teacher?
      flash[:alert] = "Apenas professores podem criar atividades."
      redirect_to proposal_path(@proposal)
      return
    end

    if @message.save
      respond_to do |format|
        format.html { redirect_to proposal_path(@proposal) }
        format.turbo_stream
      end
    else
      flash[:alert] = "Erro ao enviar mensagem: #{@message.errors.full_messages.to_sentence}"
      redirect_to proposal_path(@proposal)
    end
  end

  def answer
    @proposal = Proposal.where("student_id = ? OR teacher_id = ?", current_user.id, current_user.id).find_by(id: params[:proposal_id])
    
    unless @proposal
      flash[:alert] = "Proposta não encontrada ou acesso negado."
      redirect_to root_path
      return
    end

    @message = @proposal.messages.find(params[:id])

    unless current_user.student? && current_user.id == @proposal.student_id
      flash[:alert] = "Apenas o aluno da proposta pode responder a esta atividade."
      redirect_to proposal_path(@proposal)
      return
    end

    unless @message.activity?
      flash[:alert] = "Esta mensagem não é uma atividade."
      redirect_to proposal_path(@proposal)
      return
    end

    if @message.student_answer.present?
      flash[:alert] = "Você já respondeu a esta atividade."
      redirect_to proposal_path(@proposal)
      return
    end

    if @message.update(student_answer: params[:student_answer])
      respond_to do |format|
        format.html { redirect_to proposal_path(@proposal) }
        format.turbo_stream { render turbo_stream: turbo_stream.replace(@message) }
      end
    else
      flash[:alert] = "Erro ao enviar resposta: #{@message.errors.full_messages.to_sentence}"
      redirect_to proposal_path(@proposal)
    end
  end

  private

  def message_params
    params.require(:message).permit(:content, :attachment, :message_type, :question_type, :options)
  end
end
