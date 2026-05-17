class ProposalsController < ApplicationController
  before_action :require_login
  before_action :set_proposal, only: [:show, :update, :accept, :reject, :close, :counter]

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
    @proposal.sender = current_user
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
    if @proposal.recipient?(current_user) && @proposal.pending?
      @proposal.update(status: :accepted)
      flash[:notice] = "Proposta aceita com sucesso!"
    else
      flash[:alert] = "Ação não permitida."
    end
    redirect_to proposal_path(@proposal)
  end

  def reject
    if @proposal.recipient?(current_user) && @proposal.pending?
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

  def counter
    if !@proposal.pending?
      flash[:alert] = "Esta proposta não está pendente."
      redirect_to proposal_path(@proposal)
      return
    end

    if !@proposal.recipient?(current_user)
      flash[:alert] = "Acesso não autorizado."
      redirect_to proposal_path(@proposal)
      return
    end

    raw_price = params[:price]
    if raw_price.is_a?(String)
      price_str = raw_price.gsub("R$ ", "").strip
      if price_str.include?(",")
        price = price_str.gsub(".", "").gsub(",", ".").to_f
      else
        price = price_str.to_f
      end
    else
      price = raw_price.to_f
    end

    if price <= 0
      flash[:alert] = "Valor inválido para a contra-proposta."
      redirect_to proposal_path(@proposal)
      return
    end

    old_price = @proposal.price
    @proposal.price = price
    @proposal.sender = current_user
    @proposal.status = :pending

    if @proposal.save
      formatted_old = helpers.number_to_currency(old_price)
      formatted_new = helpers.number_to_currency(price)
      system_text = "Fez uma contra-proposta de #{formatted_new} (valor anterior: #{formatted_old})."
      
      @proposal.messages.create!(
        user: current_user,
        content: system_text,
        message_type: :regular
      )

      flash[:notice] = "Contra-proposta enviada com sucesso!"
    else
      flash[:alert] = "Não foi possível enviar a contra-proposta: " + @proposal.errors.full_messages.to_sentence
    end
    redirect_to proposal_path(@proposal)
  end

  def update
    new_status = params[:status]
    # Only the recipient can accept/reject
    if !@proposal.recipient?(current_user) && %w[accepted rejected].include?(new_status)
      flash[:alert] = "Apenas o destinatário pode aceitar ou recusar propostas."
      redirect_to proposal_path(@proposal)
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
    p = params.require(:proposal).permit(:teacher_id, :student_id, :subject_id, :price)
    if p[:price].is_a?(String)
      price_str = p[:price].gsub("R$ ", "").strip
      if price_str.include?(",")
        p[:price] = price_str.gsub(".", "").gsub(",", ".")
      else
        p[:price] = price_str
      end
    end
    p
  end
end
