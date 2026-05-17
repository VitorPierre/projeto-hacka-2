class Admin::ModerationController < Admin::BaseController
  def index
    @tab = params[:tab] || 'suspicious'

    if @tab == 'all'
      @users = User.all
    else
      @users = User.suspicious
    end

    # Busca por Nome ou E-mail
    if params[:search].present?
      search_query = "%#{params[:search]}%"
      if @users.is_a?(ActiveRecord::Relation)
        @users = @users.where("name LIKE ? OR email LIKE ?", search_query, search_query)
      else
        @users = @users.select { |u| u.name.downcase.include?(params[:search].downcase) || u.email.downcase.include?(params[:search].downcase) }
      end
    end

    # Filtro por Status
    if params[:status_filter].present?
      if @users.is_a?(ActiveRecord::Relation)
        @users = @users.where(status: params[:status_filter])
      else
        @users = @users.select { |u| u.status == params[:status_filter] }
      end
    end
  end

  # Atualiza um perfil individualmente (ex: edição de nome corrigível ou ação de linha)
  def update_user
    @user = User.find(params[:user_id])
    
    if params[:name].present?
      @user.name = params[:name]
    end
    
    if params[:status].present?
      @user.status = params[:status]
    end
    
    if params[:moderation_status].present?
      @user.moderation_status = params[:moderation_status]
    end

    if @user.save
      AuditLog.create!(
        admin: current_user,
        admin_email: current_user.email,
        action: "update_user",
        target: @user,
        target_name: @user.name,
        details: "Atualizou o perfil individual. Nome: '#{@user.name}', Status: #{@user.status}, Moderação: #{@user.moderation_status}"
      )
      Rails.logger.warn "[AUDIT ADMIN] Perfil de usuário ID: #{@user.id} atualizado. Nome: '#{@user.name}', Status: #{@user.status}, Moderação: #{@user.moderation_status} por Admin: #{current_user.email}"
      flash[:notice] = "Perfil de #{@user.name} atualizado com sucesso!"
    else
      flash[:alert] = "Erro ao atualizar: #{@user.errors.full_messages.join(', ')}"
    end

    redirect_to admin_moderation_index_path(tab: params[:tab], search: params[:search], status_filter: params[:status_filter])
  end

  # Executa ações em lote selecionadas pelo admin
  def batch_action
    user_ids = params[:user_ids] || []
    action_type = params[:action_type]

    if user_ids.empty?
      flash[:alert] = "Nenhum perfil selecionado."
      redirect_to admin_moderation_index_path(tab: params[:tab], search: params[:search], status_filter: params[:status_filter])
      return
    end

    users = User.where(id: user_ids)
    count = 0

    case action_type
    when 'mark_safe'
      users.each do |user|
        user.moderation_status = :reviewed_safe
        if user.save
          count += 1
          AuditLog.create!(
            admin: current_user,
            admin_email: current_user.email,
            action: "mark_safe",
            target: user,
            target_name: user.name,
            details: "Marcou perfil como revisado e seguro."
          )
          Rails.logger.warn "[AUDIT ADMIN LOTE] Perfil ID: #{user.id} marcado como REVISADO/SEGURO por Admin: #{current_user.email}"
        end
      end
      flash[:notice] = "#{count} perfis marcados como revisados e seguros."
    when 'suspend'
      users.each do |user|
        user.status = :suspended
        if user.save
          count += 1
          AuditLog.create!(
            admin: current_user,
            admin_email: current_user.email,
            action: "suspend",
            target: user,
            target_name: user.name,
            details: "Suspendeu a conta do usuário."
          )
          Rails.logger.warn "[AUDIT ADMIN LOTE] Perfil ID: #{user.id} SUSPENSO por Admin: #{current_user.email}"
        end
      end
      flash[:notice] = "#{count} perfis suspensos com sucesso."
    when 'ban'
      users.each do |user|
        user.status = :banned
        if user.save
          count += 1
          AuditLog.create!(
            admin: current_user,
            admin_email: current_user.email,
            action: "ban",
            target: user,
            target_name: user.name,
            details: "Baniu permanentemente a conta do usuário."
          )
          Rails.logger.warn "[AUDIT ADMIN LOTE] Perfil ID: #{user.id} BANIDO por Admin: #{current_user.email}"
        end
      end
      flash[:notice] = "#{count} perfis banidos com sucesso."
    else
      flash[:alert] = "Ação em lote inválida."
    end

    redirect_to admin_moderation_index_path(tab: params[:tab], search: params[:search], status_filter: params[:status_filter])
  end
end

