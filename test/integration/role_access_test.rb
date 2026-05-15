require "test_helper"

class RoleAccessTest < ActionDispatch::IntegrationTest
  setup do
    @student = users(:student)
    @teacher = users(:teacher)
  end

  test "student accessing students index redirects to teachers" do
    post login_path, params: { email: @student.email, password: "senha123" }
    
    get students_path
    assert_redirected_to teachers_path
    assert_equal "Você só tem acesso a professores ou ao seu painel.", flash[:alert]
  end

  test "teacher accessing teachers index redirects to students" do
    post login_path, params: { email: @teacher.email, password: "senha123" }
    
    get teachers_path
    assert_redirected_to students_path
    assert_equal "Você só tem acesso a alunos ou ao seu painel.", flash[:alert]
  end

  test "student can access their own panel but not other students" do
    post login_path, params: { email: @student.email, password: "senha123" }
    
    get student_path(@student)
    assert_response :success

    other_student = User.create!(name: "Outro", email: "outro@aluno.com", password: "pw", role: "student")
    get student_path(other_student)
    assert_redirected_to teachers_path
  end

  test "teacher can access their own panel but not other teachers" do
    post login_path, params: { email: @teacher.email, password: "senha123" }
    
    get teacher_path(@teacher)
    assert_response :success

    other_teacher = User.create!(name: "Outro T", email: "outrot@prof.com", password: "pw", role: "teacher", education_level: "technical", certificate_url: "link")
    get teacher_path(other_teacher)
    assert_redirected_to students_path
  end
end
