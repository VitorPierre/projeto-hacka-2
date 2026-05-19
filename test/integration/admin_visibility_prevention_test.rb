require "test_helper"

class AdminVisibilityPreventionTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @student = users(:student)
    @teacher = users(:teacher)
    
    ModerationService.clear_cache!
  end

  test "admin users do not appear in public teachers listing" do
    # Loga como estudante
    post "/login", params: { email: @student.email, password: "senha123" }
    follow_redirect!

    get "/teachers"
    assert_response :success
    # O professor normal deve aparecer
    assert_select "h2", text: @teacher.name
    # O admin (que tem role teacher) NÃO deve aparecer
    assert_select "h2", text: @admin.name, count: 0
  end

  test "admin users do not appear in landing page feeds" do
    get "/"
    assert_response :success
    
    # O admin NÃO deve aparecer
    assert_select "h2", text: @admin.name, count: 0
  end

  test "accessing admin profile as a teacher via show action returns 404 for students" do
    # Loga como estudante
    post "/login", params: { email: @student.email, password: "senha123" }
    follow_redirect!

    # Tenta acessar o perfil público do admin como se fosse professor
    get "/teachers/#{@admin.id}"
    assert_response :not_found
  end

  test "accessing admin profile via show action is allowed for administrators" do
    # Loga como administrador
    post "/login", params: { email: @admin.email, password: "senha123" }
    follow_redirect!

    # Admin visualiza o próprio perfil (ou outro admin)
    get "/teachers/#{@admin.id}"
    assert_response :success
  end

  test "proposals involving admin as student or teacher are invalid and blocked" do
    # Caso 1: Admin como professor
    proposal = Proposal.new(
      student: @student,
      teacher: @admin, # Admin
      subject: subjects(:math),
      sender: @student,
      price: 100.0,
      modality: :focused_mentoring,
      duration: 60
    )
    assert_not proposal.valid?
    assert_includes proposal.errors[:teacher], "com perfil de administrador não pode participar de propostas"

    # Caso 2: Admin como estudante
    # Mudamos temporariamente a flag do admin para atuar como estudante para testar a validação
    @admin.update_columns(role: :student)
    
    proposal2 = Proposal.new(
      student: @admin, # Admin como estudante
      teacher: @teacher,
      subject: subjects(:math),
      sender: @teacher,
      price: 100.0,
      modality: :focused_mentoring,
      duration: 60
    )
    assert_not proposal2.valid?
    assert_includes proposal2.errors[:student], "com perfil de administrador não pode participar de propostas"
  end

  test "admin users remain fully visible in the admin moderation dashboard" do
    # Loga como admin
    post "/login", params: { email: @admin.email, password: "senha123" }
    follow_redirect!

    get "/admin/moderation", params: { tab: "all" }
    assert_response :success
    # Admin deve estar listado no painel administrativo
    assert_select "div", text: @admin.email
  end
end
