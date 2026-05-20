require "test_helper"

class BannedUsersVisibilityTest < ActionDispatch::IntegrationTest
  setup do
    @student = users(:student)
    @teacher = users(:teacher)
    @admin = users(:admin)

    # Configura um professor banido
    @banned_teacher = users(:uncertified_teacher)
    @banned_teacher.update_column(:status, :banned)

    # Configura um aluno banido
    @banned_student = users(:suspicious_user)
    @banned_student.update_columns(status: :banned, role: :student)
  end

  test "banned teacher is hidden from teachers list and home page" do
    # Visitante na home
    get root_path
    assert_response :success
    assert_select "h2", text: @banned_teacher.name, count: 0

    # Aluno logado na lista de professores
    post "/login", params: { email: @student.email, password: "senha123" }
    follow_redirect!

    get teachers_path
    assert_response :success
    assert_select "h2", text: @banned_teacher.name, count: 0
  end

  test "banned student is hidden from students list and home page" do
    # Visitante na home
    get root_path
    assert_response :success
    assert_select "h2", text: @banned_student.name, count: 0

    # Professor logado na lista de alunos
    post "/login", params: { email: @teacher.email, password: "senha123" }
    follow_redirect!

    get students_path
    assert_response :success
    assert_select "h2", text: @banned_student.name, count: 0
  end

  test "public show pages of banned users return 404 RecordNotFound for ordinary users or visitors" do
    # Professor banido acessado por aluno
    post "/login", params: { email: @student.email, password: "senha123" }
    follow_redirect!

    get teacher_path(@banned_teacher)
    assert_response :not_found

    # Aluno banido acessado por professor
    post "/login", params: { email: @teacher.email, password: "senha123" }
    follow_redirect!

    get student_path(@banned_student)
    assert_response :not_found
  end

  test "admins can still view public show pages of banned users" do
    post "/login", params: { email: @admin.email, password: "senha123" }
    follow_redirect!

    get teacher_path(@banned_teacher)
    assert_response :success
    assert_select "h1", text: /Perfil/

    get student_path(@banned_student)
    assert_response :success
    assert_select "h1", text: /Perfil/
  end

  test "cannot initiate new proposals involving banned users" do
    # Aluno tentando propor para professor banido
    post "/login", params: { email: @student.email, password: "senha123" }
    follow_redirect!

    get new_proposal_path(teacher_id: @banned_teacher.id)
    assert_response :not_found

    # Professor tentando propor para aluno banido (bloqueado por não ser aluno)
    post "/login", params: { email: @teacher.email, password: "senha123" }
    follow_redirect!

    get new_proposal_path(student_id: @banned_student.id)
    assert_redirected_to root_path
    assert_equal "Acesso restrito para alunos.", flash[:alert]
  end

  test "proposal model validation prevents saving proposals with banned users" do
    # Tentativa direta de salvar no banco gera falha de validação
    subject = subjects(:math) || Subject.create!(name: "Matemática")
    
    proposal = Proposal.new(
      student: @student,
      teacher: @banned_teacher,
      subject: subject,
      sender: @student,
      price: 50.0,
      modality: :focused_mentoring,
      duration: 30
    )
    assert_not proposal.save
    assert_includes proposal.errors[:teacher], "está banido e não pode participar de propostas"

    proposal2 = Proposal.new(
      student: @banned_student,
      teacher: @teacher,
      subject: subject,
      sender: @teacher,
      price: 50.0,
      modality: :focused_mentoring,
      duration: 30
    )
    assert_not proposal2.save
    assert_includes proposal2.errors[:student], "está banido e não pode participar de propostas"
  end
end
