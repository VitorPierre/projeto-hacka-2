require "test_helper"

class AdminAuditLogsTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @student = users(:student)
    @suspicious = users(:suspicious_user)
    
    ModerationService.clear_cache!
  end

  test "public endpoint users check_moderation returns JSON appropriate/inappropriate status" do
    # Caso 1: Nome adequado
    post "/users/check_moderation", params: { text: "Vitor Pierre" }, as: :json
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal false, json_response["inappropriate"]

    # Caso 2: Nome inadequado contendo blacklist
    post "/users/check_moderation", params: { text: "bobo" }, as: :json
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal true, json_response["inappropriate"]
  end

  test "non-admin users cannot access admin audit logs" do
    # Tenta sem login
    get "/admin/audit_logs"
    assert_redirected_to login_path

    # Loga como estudante comum
    post "/login", params: { email: @student.email, password: "senha123" }
    follow_redirect!
    
    get "/admin/audit_logs"
    assert_redirected_to root_path
    follow_redirect!
    assert_equal "Acesso restrito para administradores.", flash[:alert]
  end

  test "admin moderation actions create AuditLog records and are listed in the audit history" do
    # Loga como administrador
    post "/login", params: { email: @admin.email, password: "senha123" }
    follow_redirect!

    # 1. Realiza uma ação de moderação individual (update_user)
    assert_difference "AuditLog.count", 1 do
      patch "/admin/moderation/update_user", params: { 
        user_id: @suspicious.id, 
        name: "Renato Safe", 
        moderation_status: "reviewed_safe" 
      }
    end

    last_log = AuditLog.last
    assert_equal "update_user", last_log.action
    assert_equal @admin.id, last_log.admin_id
    assert_equal @suspicious.id, last_log.target_id
    assert_equal "Renato Safe", last_log.target_name
    assert_match "Atualizou o perfil individual", last_log.details

    # 2. Realiza uma ação em lote (batch suspend)
    assert_difference "AuditLog.count", 1 do
      post "/admin/moderation/batch_action", params: { 
        user_ids: [@suspicious.id], 
        action_type: "suspend" 
      }
    end

    last_log = AuditLog.last
    assert_equal "suspend", last_log.action
    assert_match "Suspendeu a conta", last_log.details

    # 3. Acessa a página de histórico de auditoria
    get "/admin/audit_logs"
    assert_response :success
    assert_select "h1", text: "Histórico de Auditoria"
    assert_select "p", text: @admin.email
    assert_select "span", text: "Suspensão"
  end
end
