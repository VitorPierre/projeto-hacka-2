require "test_helper"

class AdminModerationTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @student = users(:student)
    @suspicious = users(:suspicious_user)
    
    # Certifica-se de limpar cache de moderação antes de rodar os testes
    ModerationService.clear_cache!
  end

  test "non-admin users cannot access moderation panel" do
    # Aluno tenta acessar
    post "/login", params: { email: @student.email, password: "senha123" }
    follow_redirect!
    assert_equal @student.id, session[:user_id]

    get "/admin/moderation"
    assert_redirected_to root_path
    follow_redirect!
    assert_equal "Acesso restrito para administradores.", flash[:alert]
  end

  test "admin users can access moderation panel and see suspicious profiles" do
    # Entra como admin
    post "/login", params: { email: @admin.email, password: "senha123" }
    follow_redirect!
    assert_equal @admin.id, session[:user_id]

    get "/admin/moderation"
    assert_response :success
    assert_select "h1", "Painel de Moderação"
    
    # O usuário suspeito "bobo" deve ser listado
    assert_select "span", text: "bobo"
  end

  test "admin can edit a user name to be safe" do
    post "/login", params: { email: @admin.email, password: "senha123" }
    follow_redirect!

    patch "/admin/moderation/update_user", params: { user_id: @suspicious.id, name: "Roberto Safe" }
    assert_redirected_to admin_moderation_index_path
    follow_redirect!

    @suspicious.reload
    assert_equal "Roberto Safe", @suspicious.name
    # Agora o perfil não deve mais ser suspeito
    assert_not @suspicious.suspicious?
  end

  test "admin can mark a user as reviewed safe" do
    post "/login", params: { email: @admin.email, password: "senha123" }
    follow_redirect!

    patch "/admin/moderation/update_user", params: { user_id: @suspicious.id, moderation_status: "reviewed_safe" }
    assert_redirected_to admin_moderation_index_path
    follow_redirect!

    @suspicious.reload
    assert @suspicious.reviewed_safe?
    # Mesmo com o nome "bobo", agora ele foi revisado e não é classificado como suspeito
    assert_not @suspicious.suspicious?
  end

  test "admin can suspend and ban users individually" do
    post "/login", params: { email: @admin.email, password: "senha123" }
    follow_redirect!

    # Suspende
    patch "/admin/moderation/update_user", params: { user_id: @suspicious.id, status: "suspended" }
    assert_redirected_to admin_moderation_index_path
    @suspicious.reload
    assert @suspicious.suspended?

    # Bane
    patch "/admin/moderation/update_user", params: { user_id: @suspicious.id, status: "banned" }
    assert_redirected_to admin_moderation_index_path
    @suspicious.reload
    assert @suspicious.banned?
  end

  test "admin can perform batch action: mark safe" do
    post "/login", params: { email: @admin.email, password: "senha123" }
    follow_redirect!

    post "/admin/moderation/batch_action", params: { user_ids: [@suspicious.id], action_type: "mark_safe" }
    assert_redirected_to admin_moderation_index_path
    follow_redirect!
    assert_match "perfis marcados como revisados e seguros", flash[:notice]

    @suspicious.reload
    assert @suspicious.reviewed_safe?
  end

  test "admin can perform batch action: suspend" do
    post "/login", params: { email: @admin.email, password: "senha123" }
    follow_redirect!

    post "/admin/moderation/batch_action", params: { user_ids: [@suspicious.id], action_type: "suspend" }
    assert_redirected_to admin_moderation_index_path
    follow_redirect!
    assert_match "perfis suspensos com sucesso", flash[:notice]

    @suspicious.reload
    assert @suspicious.suspended?
  end

  test "admin can perform batch action: ban" do
    post "/login", params: { email: @admin.email, password: "senha123" }
    follow_redirect!

    post "/admin/moderation/batch_action", params: { user_ids: [@suspicious.id], action_type: "ban" }
    assert_redirected_to admin_moderation_index_path
    follow_redirect!
    assert_match "perfis banidos com sucesso", flash[:notice]

    @suspicious.reload
    assert @suspicious.banned?
  end

  test "suspended or banned users cannot log in" do
    @suspicious.suspended!
    post "/login", params: { email: @suspicious.email, password: "senha123" }
    assert_response :unprocessable_entity
    assert_match "Sua conta está suspensa temporariamente", flash[:alert]

    @suspicious.banned!
    post "/login", params: { email: @suspicious.email, password: "senha123" }
    assert_response :unprocessable_entity
    assert_match "Sua conta foi banida permanentemente", flash[:alert]
  end

  test "currently active session of user gets closed if suspended or banned" do
    # Simula login com sucesso
    post "/login", params: { email: @student.email, password: "senha123" }
    follow_redirect!
    assert_equal @student.id, session[:user_id]

    # Suspende o estudante em segundo plano
    @student.suspended!

    # Qualquer requisição subsequente deve deslogar e bloquear
    get "/teachers"
    assert_nil session[:user_id]
  end
end
