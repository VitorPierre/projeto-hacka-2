class Admin::AuditLogsController < Admin::BaseController
  def index
    @audit_logs = AuditLog.includes(:admin, :target).order(created_at: :desc)

    # Busca por Admin, Alvo ou Detalhes
    if params[:search].present?
      search_query = "%#{params[:search]}%"
      @audit_logs = @audit_logs.where(
        "admin_email LIKE ? OR target_name LIKE ? OR details LIKE ?",
        search_query, search_query, search_query
      )
    end

    # Filtro por tipo de Ação
    if params[:action_filter].present?
      @audit_logs = @audit_logs.where(action: params[:action_filter])
    end
  end
end
