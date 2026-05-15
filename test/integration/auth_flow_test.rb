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

    post users_path, params: { user: { name: "Novo Aluno", email: "novo@aluno.com", password: "pw", role: "student" } }
    
    user = User.find_by(email: "novo@aluno.com")
    assert user
    assert_redirected_to student_path(user)
    assert user.student?
  end

  test "teacher sign up is uncertified by default" do
    post users_path, params: { user: { name: "Novo Prof", email: "novo@prof.com", password: "pw", role: "teacher", education_level: "technical", certificate_url: "http://link.com", subject_ids: [subjects(:math).id] } }
    
    user = User.find_by(email: "novo@prof.com")
    assert user
    assert_redirected_to teacher_path(user)
    assert user.teacher?
    assert_not user.certified?
    assert_includes user.subjects, subjects(:math)
  end
end
