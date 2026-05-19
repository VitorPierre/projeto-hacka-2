class ProposalsController < ApplicationController
  before_action :require_login
  before_action :set_proposal, only: [:show, :update, :accept, :reject, :close, :counter, :pay, :schedule, :start_session, :finish_session, :rate]

  def new
    if current_user.student?
      @teacher = User.certified_teachers.find(params[:teacher_id])
      @student = current_user
    elsif current_user.teacher?
      @student = User.student.public_view.find(params[:student_id])
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
      if @proposal.knowledge_pill? && (params[:message_content].present? || params[:attachment].present?)
        @proposal.messages.create(
          user: current_user,
          content: params[:message_content] || "Dúvida enviada via anexo.",
          attachment: params[:attachment],
          message_type: :regular
        )
      end

      [@proposal.student, @proposal.teacher].each do |u|
        prefix = u.id == current_user.id ? "Você enviou uma" : "Você recebeu uma"
        Notification.create(user: u, message: "#{prefix} nova proposta de #{current_user.name} em #{@proposal.subject.name}.", url: "/proposals/#{@proposal.id}")
      end
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
      notify_both("A proposta '#{@proposal.subject.name}' foi aceita por #{current_user.name}.")
      flash[:notice] = "Proposta aceita com sucesso!"
    else
      flash[:alert] = "Ação não permitida."
    end
    redirect_to proposal_path(@proposal)
  end

  def reject
    if @proposal.recipient?(current_user) && @proposal.pending?
      @proposal.update(status: :rejected)
      notify_both("A proposta '#{@proposal.subject.name}' foi recusada por #{current_user.name}.")
      flash[:notice] = "Proposta recusada."
    else
      flash[:alert] = "Ação não permitida."
    end
    redirect_to proposal_path(@proposal)
  end

  def close
    if @proposal.accepted? && current_user == @proposal.teacher
      attributes = { status: :closed }
      msg = "A proposta '#{@proposal.subject.name}' foi fechada por #{current_user.name}."
      
      if @proposal.price.to_f == 0.0 && @proposal.knowledge_pill?
        attributes[:paid] = true
        attributes[:started_at] = Time.current
        msg += " Como a pílula é gratuita, ela foi ativada automaticamente!"
      end
      
      @proposal.update(attributes)
      notify_both(msg)
      flash[:notice] = "Proposta fechada com sucesso!"
    else
      flash[:alert] = "Ação não permitida."
    end
    redirect_to proposal_path(@proposal)
  end

  def pay
    if @proposal.closed? && !@proposal.paid? && current_user == @proposal.student
      attributes = { paid: true }
      attributes[:started_at] = Time.current if @proposal.knowledge_pill?
      
      @proposal.update(attributes)
      notify_both("Pagamento confirmado para a proposta '#{@proposal.subject.name}'.")
      flash[:notice] = "Pagamento simulado com sucesso!"
    else
      flash[:alert] = "Não foi possível realizar o pagamento."
    end
    redirect_to proposal_path(@proposal)
  end

  def schedule
    if @proposal.closed? && @proposal.paid? && current_user == @proposal.teacher
      if params[:scheduled_at].present?
        @proposal.update(scheduled_at: params[:scheduled_at])
        notify_both("Aula de '#{@proposal.subject.name}' agendada para #{I18n.l(@proposal.scheduled_at.to_time, format: :short)}.")
        flash[:notice] = "Aula agendada com sucesso."
      else
        flash[:alert] = "Selecione uma data e hora."
      end
    else
      flash[:alert] = "Ação não permitida."
    end
    redirect_to proposal_path(@proposal)
  end

  def start_session
    if @proposal.closed? && @proposal.paid? && current_user == @proposal.teacher
      @proposal.update(started_at: Time.current)
      notify_both("A aula de '#{@proposal.subject.name}' foi iniciada.")
      flash[:notice] = "Aula iniciada. O chat e vídeo estão ativos."
    else
      flash[:alert] = "Ação não permitida."
    end
    redirect_to proposal_path(@proposal)
  end

  def finish_session
    if @proposal.started_at.present? && @proposal.finished_at.nil? && current_user == @proposal.teacher
      attributes = { finished_at: Time.current }
      if @proposal.synchronous?
        attributes[:recording_url] = "https://meet.jit.si/aprendeai-proposal-#{@proposal.id}#recording_#{Time.current.to_i}"
      end
      @proposal.update(attributes)
      notify_both("A aula de '#{@proposal.subject.name}' foi finalizada.")
      flash[:notice] = "Aula finalizada com sucesso."
    else
      flash[:alert] = "Ação não permitida."
    end
    redirect_to proposal_path(@proposal)
  end

  def rate
    if @proposal.finished_at.present? && current_user == @proposal.student
      if @proposal.update(rating: params[:rating], feedback: params[:feedback])
        notify_both("O aluno avaliou a sessão de '#{@proposal.subject.name}'.")
        flash[:notice] = "Avaliação enviada com sucesso!"
      else
        flash[:alert] = "Não foi possível enviar a avaliação."
      end
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
      
      notify_both("#{current_user.name} fez uma contra-proposta de #{formatted_new} na proposta '#{@proposal.subject.name}'.")

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

  def notify_both(msg)
    [@proposal.student, @proposal.teacher].each do |u|
      Notification.create(
        user: u,
        message: msg,
        url: "/proposals/#{@proposal.id}"
      )
    end
  end

  def set_proposal
    @proposal = Proposal.where("student_id = ? OR teacher_id = ?", current_user.id, current_user.id).find_by(id: params[:id])
    unless @proposal
      flash[:alert] = "Proposta não encontrada ou acesso negado."
      redirect_to root_path
    end
  end

  def proposal_params
    p = params.require(:proposal).permit(:teacher_id, :student_id, :subject_id, :price, :modality, :duration)
    if p[:price].is_a?(String)
      price_str = p[:price].gsub("R$ ", "").strip
      if price_str.include?(",")
        p[:price] = price_str.gsub(".", "").gsub(",", ".")
      else
        p[:price] = price_str
      end
    end
    
    # Convert duration to int or nil based on modality
    if p[:modality] == "knowledge_pill"
      p[:duration] = nil
    elsif p[:duration].present?
      p[:duration] = p[:duration].to_i
    end
    
    p
  end
end
