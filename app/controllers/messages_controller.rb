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

    if @message.save
      redirect_to proposal_path(@proposal)
    else
      flash[:alert] = "Erro ao enviar mensagem: #{@message.errors.full_messages.to_sentence}"
      redirect_to proposal_path(@proposal)
    end
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end
end
