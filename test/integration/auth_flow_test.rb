require "test_helper"

class AuthFlowTest < ActionDispatch::IntegrationTest
  test "can login and logout" do
    get login_path
    assert_response :success

    post login_path, params: { email: "aluno@teste.com", password: "senha123" }
    assert_redirected_to student_path(users(:student))
    follow_redirect!
    assert_match "Bem-vindo", response.body

    delete logout_path
    assert_redirected_to root_path
    follow_redirect!
    assert_match "Desconectado", response.body
  end

  test "student sign up" do
    get new_user_path(role: "student")
    assert_response :success

    post users_path, params: { user: { name: "Novo Aluno", email: "novo@aluno.com", password: "pw", role: "student", phone: "11999999999", cpf: "11111111111", terms_acceptance: "1" } }
    
    user = User.find_by(email: "novo@aluno.com")
    assert user
    assert_redirected_to student_path(user)
    assert user.student?
  end

  test "teacher sign up is uncertified by default" do
    post users_path, params: { user: { name: "Novo Prof", email: "novo@prof.com", password: "pw", role: "teacher", education_level: "technical", certificate_url: "http://link.com", subject_ids: [subjects(:math).id], phone: "11988888888", cpf: "22222222222", terms_acceptance: "1" } }
    
    user = User.find_by(email: "novo@prof.com")
    assert user
    assert_redirected_to teacher_path(user)
    assert user.teacher?
    assert_not user.certified?
    assert_includes user.subjects, subjects(:math)
  end

  test "sign up fails without terms acceptance" do
    get new_user_path(role: "student")
    assert_response :success

    post users_path, params: { user: { name: "Aluno Sem Termos", email: "semtermos@aluno.com", password: "pw", role: "student", phone: "11999999999", cpf: "11111111111", terms_acceptance: "0" } }
    
    user = User.find_by(email: "semtermos@aluno.com")
    assert_nil user
    assert_response :unprocessable_entity
    assert_match "deve ser aceito para prosseguir", response.body
  end
end
