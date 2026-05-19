require "test_helper"

class NegotiationButtonTest < ActionDispatch::IntegrationTest
  setup do
    @student = users(:student)
    @teacher = users(:teacher)
    @proposal = proposals(:pending_proposal)
  end

  # --- Professor visiting student profile ---

  test "teacher sees Fazer Proposta button on student profile" do
    # Create a student without existing proposal with this teacher
    other_student = User.create!(name: "Outro Aluno", email: "outro_aluno@teste.com", password: "senha123", role: "student", phone: "11999999999", cpf: "11111111111")

    post login_path, params: { email: @teacher.email, password: "senha123" }
    get student_path(other_student)
    assert_response :success
    assert_select "a", text: /Fazer Proposta/
  end

  test "teacher sees Negociação em andamento on student profile when active proposal exists" do
    post login_path, params: { email: @teacher.email, password: "senha123" }
    get student_path(@student)
    assert_response :success
    assert_select "a", text: /Negociação em andamento/
  end

  # --- Student visiting teacher profile ---

  test "student sees Fazer Proposta button on teacher profile" do
    # Create a new certified teacher with no active proposal
    other_teacher = User.create!(name: "Outro Prof", email: "outroprof@teste.com", password: "senha123", role: "teacher", education_level: "technical", certificate_url: "http://cert.com", certified: true, phone: "11988888888", cpf: "22222222222")
    other_teacher.subjects << subjects(:math)

    post login_path, params: { email: @student.email, password: "senha123" }
    get teacher_path(other_teacher)
    assert_response :success
    assert_select "a", text: /Fazer Proposta/
  end

  test "student sees Negociação em andamento on teacher profile when active proposal exists" do
    post login_path, params: { email: @student.email, password: "senha123" }
    get teacher_path(@teacher)
    assert_response :success
    assert_select "a", text: /Negociação em andamento/
  end

  # --- Own profile: no button ---

  test "student does not see Fazer Proposta on own profile" do
    post login_path, params: { email: @student.email, password: "senha123" }
    get student_path(@student)
    assert_response :success
    assert_select "a", text: /Fazer Proposta/, count: 0
  end

  test "teacher does not see Fazer Proposta on own profile" do
    post login_path, params: { email: @teacher.email, password: "senha123" }
    get teacher_path(@teacher)
    assert_response :success
    assert_select "a", text: /Fazer Proposta/, count: 0
  end

  # --- Route and action ---

  test "teacher can access new proposal form for a student" do
    other_student = User.create!(name: "Aluno Form", email: "form_aluno@teste.com", password: "senha123", role: "student", phone: "11977777777", cpf: "33333333333")
    other_student.subjects << subjects(:math)

    post login_path, params: { email: @teacher.email, password: "senha123" }
    get new_proposal_path(student_id: other_student.id)
    assert_response :success
    assert_select "input[name='proposal[student_id]'][value='#{other_student.id}']"
  end

  test "teacher can submit a proposal for a student" do
    other_student = User.create!(name: "Aluno Submit", email: "submit_aluno@teste.com", password: "senha123", role: "student", phone: "11966666666", cpf: "44444444444")
    other_student.subjects << subjects(:math)

    post login_path, params: { email: @teacher.email, password: "senha123" }

    assert_difference "Proposal.count", 1 do
      post proposals_path, params: {
        proposal: {
          student_id: other_student.id,
          subject_id: subjects(:math).id,
          price: 75.0,
          modality: "focused_mentoring",
          duration: 1
        }
      }
    end

    proposal = Proposal.last
    assert_equal @teacher.id, proposal.teacher_id
    assert_equal other_student.id, proposal.student_id
    assert_equal @teacher.id, proposal.sender_id
    assert_redirected_to proposal_path(proposal)
  end

  test "student can submit a proposal for a teacher" do
    other_teacher = User.create!(name: "Prof Submit", email: "submit_prof@teste.com", password: "senha123", role: "teacher", education_level: "technical", certificate_url: "http://cert.com", certified: true, phone: "11955555555", cpf: "66666666666")
    other_teacher.subjects << subjects(:programming)

    post login_path, params: { email: @student.email, password: "senha123" }

    assert_difference "Proposal.count", 1 do
      post proposals_path, params: {
        proposal: {
          teacher_id: other_teacher.id,
          subject_id: subjects(:programming).id,
          price: 80.0,
          modality: "focused_mentoring",
          duration: 1
        }
      }
    end

    proposal = Proposal.last
    assert_equal @student.id, proposal.student_id
    assert_equal other_teacher.id, proposal.teacher_id
    assert_equal @student.id, proposal.sender_id
    assert_redirected_to proposal_path(proposal)
  end
end
