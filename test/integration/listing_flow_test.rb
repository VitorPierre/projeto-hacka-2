require "test_helper"

class ListingFlowTest < ActionDispatch::IntegrationTest
  setup do
    @student = users(:student)
    @teacher = users(:teacher)
  end

  # === ALUNO VÊ PROFESSORES ===

  test "student sees teachers list with Fazer Proposta button" do
    post login_path, params: { email: @student.email, password: "senha123" }

    get teachers_path
    assert_response :success
    assert_select "h2", text: /Professores Disponíveis/
    assert_select "h3", text: @teacher.name
    assert_select "a", text: "Fazer Proposta"
  end

  test "student is redirected away from students index" do
    post login_path, params: { email: @student.email, password: "senha123" }

    get students_path
    assert_redirected_to teachers_path
  end

  # === PROFESSOR VÊ ALUNOS ===

  test "teacher sees students list with Ver Perfil button" do
    post login_path, params: { email: @teacher.email, password: "senha123" }

    get students_path
    assert_response :success
    assert_select "h2", text: /Alunos Disponíveis/
    assert_select "h3", text: @student.name
    assert_select "a", text: "Ver Perfil"
  end

  test "teacher is redirected away from teachers index" do
    post login_path, params: { email: @teacher.email, password: "senha123" }

    get teachers_path
    assert_redirected_to students_path
  end

  # === PERFIS INDIVIDUAIS ===

  test "student sees Fazer Proposta on teacher profile" do
    post login_path, params: { email: @student.email, password: "senha123" }

    get teacher_path(@teacher)
    assert_response :success
    assert_select "a", text: "Fazer Proposta"
  end

  test "Fazer Proposta route works for student" do
    post login_path, params: { email: @student.email, password: "senha123" }

    get new_proposal_path(teacher_id: @teacher.id)
    assert_response :success
    assert_select "h2", text: /Enviar Proposta/
  end

  # === VISITANTE ===

  test "visitor sees teachers list with login prompt" do
    get teachers_path
    assert_response :success
    assert_select "a", text: "Entrar para Fazer Proposta"
  end
end
