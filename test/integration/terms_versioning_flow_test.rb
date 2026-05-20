require "test_helper"

class TermsVersioningFlowTest < ActionDispatch::IntegrationTest
  setup do
    @student = users(:student)
    @teacher = users(:teacher)
  end

  test "new signup records terms and privacy acceptance versions and timestamp" do
    post users_path, params: {
      user: {
        name: "Novo Aluno Teste",
        email: "novo.aluno.teste@exemplo.com",
        password: "password123",
        role: "student",
        phone: "11911112222",
        cpf: "12345678901",
        terms_acceptance: "1"
      }
    }

    user = User.find_by(email: "novo.aluno.teste@exemplo.com")
    assert user
    assert_equal "1.0", user.terms_accepted_version
    assert_equal "1.0", user.privacy_accepted_version
    assert_not_nil user.terms_accepted_at
    assert_redirected_to student_path(user)
  end

  test "logged in user with outdated terms is redirected to accept_terms page" do
    # Simulates an outdated user by clearing their accepted version
    @student.update_columns(terms_accepted_version: "0.9", privacy_accepted_version: "0.9")

    # Perform login
    post login_path, params: { email: @student.email, password: "senha123" }
    assert_redirected_to student_path(@student)
    follow_redirect!

    # Should be intercepted and redirected to accept_terms
    assert_redirected_to accept_terms_path
    follow_redirect!
    assert_match "Atualizamos nossos Termos de Uso e Política de Privacidade", response.body
  end

  test "logged in user with outdated terms can access terms, privacy, and logout pages without redirect loop" do
    @student.update_columns(terms_accepted_version: nil, privacy_accepted_version: nil)

    # Perform login
    post login_path, params: { email: @student.email, password: "senha123" }
    assert_redirected_to student_path(@student)
    follow_redirect!
    assert_redirected_to accept_terms_path
    follow_redirect!

    # Can access /terms
    get terms_path
    assert_response :success
    assert_match "Termos de Uso", response.body

    # Can access /privacy
    get privacy_path
    assert_response :success
    assert_match "Política de Privacidade", response.body

    # Can logout
    delete logout_path
    assert_redirected_to root_path
    follow_redirect!
    assert_match "Desconectado", response.body
  end

  test "submitting accept_terms form with checkbox checked updates user and allows navigation" do
    @student.update_columns(terms_accepted_version: "0.9", privacy_accepted_version: "0.9", terms_accepted_at: 1.day.ago)

    # Perform login and get redirected
    post login_path, params: { email: @student.email, password: "senha123" }
    assert_redirected_to student_path(@student)
    follow_redirect!
    assert_redirected_to accept_terms_path
    follow_redirect!

    # Submit terms acceptance form with checkbox checked
    post accept_terms_path, params: { terms_acceptance: "1" }
    assert_redirected_to student_path(@student)
    follow_redirect!
    assert_match "Termos aceitos com sucesso", response.body

    # Verify database updates
    @student.reload
    assert_equal "1.0", @student.terms_accepted_version
    assert_equal "1.0", @student.privacy_accepted_version
    assert_in_delta Time.current, @student.terms_accepted_at, 5.seconds

    # Verify they can navigate without redirects now
    get student_path(@student)
    assert_response :success
    assert_no_match "Atualizamos nossos Termos", response.body
  end

  test "submitting accept_terms form with checkbox unchecked fails and shows alert" do
    @student.update_columns(terms_accepted_version: nil, privacy_accepted_version: nil)

    # Perform login and get redirected
    post login_path, params: { email: @student.email, password: "senha123" }
    assert_redirected_to student_path(@student)
    follow_redirect!
    assert_redirected_to accept_terms_path
    follow_redirect!

    # Submit terms acceptance form with checkbox unchecked
    post accept_terms_path, params: { terms_acceptance: "0" }
    assert_response :unprocessable_entity
    assert_match "Você precisa marcar a caixa", response.body

    # Database columns should remain unchanged
    @student.reload
    assert_nil @student.terms_accepted_version
    assert_nil @student.privacy_accepted_version
  end

  test "admin can log in, accept terms even without certificate_url, and is redirected to admin panel" do
    # Create an admin user without certificate_url
    admin = User.new(
      name: "Admin Teste",
      email: "admin_teste@aprendeai.com",
      password: "password123",
      role: :teacher,
      education_level: :higher,
      phone: "11999999999",
      cpf: "12345678900",
      certified: true,
      admin: true,
      terms_accepted_version: "0.9",
      privacy_accepted_version: "0.9"
    )
    admin.save!(validate: false)
    admin.update_columns(terms_accepted_version: "0.9", privacy_accepted_version: "0.9")

    post login_path, params: { email: admin.email, password: "password123" }
    assert_redirected_to teacher_path(admin)
    follow_redirect!
    assert_redirected_to accept_terms_path
    follow_redirect!

    # Submit terms acceptance
    post accept_terms_path, params: { terms_acceptance: "1" }
    
    # Reload and assert terms are accepted
    admin.reload
    assert_equal "1.0", admin.terms_accepted_version

    assert_redirected_to admin_moderation_index_path
  end
end
