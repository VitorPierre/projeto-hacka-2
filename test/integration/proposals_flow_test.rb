require "test_helper"

class ProposalsFlowTest < ActionDispatch::IntegrationTest
  setup do
    @student = users(:student)
    @teacher = users(:teacher)
    @subject = subjects(:math)
  end

  test "student can create a proposal and lands on negotiation page" do
    post login_path, params: { email: @student.email, password: "senha123" }

    # Criar novo subject para não esbarrar na regra de duplicidade (já existe pending_proposal)
    new_subject = Subject.create!(name: "Física")
    
    get new_proposal_path(teacher_id: @teacher.id)
    assert_response :success

    proposal = nil
    assert_difference('Proposal.count', 1) do
      post proposals_path, params: { proposal: { teacher_id: @teacher.id, subject_id: new_subject.id, price: 60.0 } }
      proposal = Proposal.last
    end

    # Agora redireciona para a página de negociação/proposta
    assert_redirected_to proposal_path(proposal)
    follow_redirect!
    assert_response :success
    assert_select "h1", text: /Proposta:/
  end

  test "teacher can accept a proposal" do
    post login_path, params: { email: @teacher.email, password: "senha123" }
    proposal = proposals(:pending_proposal)

    patch accept_proposal_path(proposal)
    assert_redirected_to proposal_path(proposal)
    
    assert proposal.reload.accepted?
  end

  test "teacher can reject a proposal" do
    post login_path, params: { email: @teacher.email, password: "senha123" }
    proposal = proposals(:pending_proposal)

    patch reject_proposal_path(proposal)
    assert_redirected_to proposal_path(proposal)
    
    assert proposal.reload.rejected?
  end

  test "participants can close an accepted proposal" do
    post login_path, params: { email: @teacher.email, password: "senha123" }
    proposal = proposals(:pending_proposal)
    proposal.update_column(:status, 1) # accepted

    patch close_proposal_path(proposal)
    assert_redirected_to proposal_path(proposal)
    
    assert proposal.reload.closed?
  end

  test "users can send messages in chat" do
    post login_path, params: { email: @student.email, password: "senha123" }
    proposal = proposals(:pending_proposal)

    get proposal_path(proposal)
    assert_response :success

    assert_difference('Message.count', 1) do
      post proposal_messages_path(proposal), params: { message: { content: "Olá professor!" } }
    end

    assert_redirected_to proposal_path(proposal)
  end

  test "empty message is not saved" do
    post login_path, params: { email: @student.email, password: "senha123" }
    proposal = proposals(:pending_proposal)

    assert_no_difference('Message.count') do
      post proposal_messages_path(proposal), params: { message: { content: "" } }
    end
  end

  test "unauthorized user cannot access the proposal" do
    other_teacher = User.create!(name: "Outro Prof", email: "outro@prof.com", password: "pw", role: "teacher", education_level: "technical", certificate_url: "link")
    post login_path, params: { email: other_teacher.email, password: "pw" }
    
    proposal = proposals(:pending_proposal)
    get proposal_path(proposal)
    
    assert_redirected_to root_path
    assert_equal "Proposta não encontrada ou acesso negado.", flash[:alert]
  end

  test "proposal show renders negotiation elements" do
    post login_path, params: { email: @student.email, password: "senha123" }
    proposal = proposals(:pending_proposal)

    get proposal_path(proposal)
    assert_response :success
    assert_select "h1", text: /Proposta:/
    assert_select "p", text: /Aluno:/
    assert_select "p", text: /Professor:/
    assert_select "p", text: /Valor:/
    assert_select "textarea" # Message form
  end

  test "teacher sees accept/reject buttons on pending proposal" do
    post login_path, params: { email: @teacher.email, password: "senha123" }
    proposal = proposals(:pending_proposal)

    get proposal_path(proposal)
    assert_response :success
    assert_select "input[value='Aceitar Proposta']"
    assert_select "input[value='Recusar']"
  end

  test "student panel links to proposal negotiation" do
    post login_path, params: { email: @student.email, password: "senha123" }
    
    get student_path(@student)
    assert_response :success
    assert_select "a[href='#{proposal_path(proposals(:pending_proposal))}']", text: /Ver Detalhes/
  end

  test "teacher panel links to proposal negotiation" do
    post login_path, params: { email: @teacher.email, password: "senha123" }
    
    get teacher_path(@teacher)
    assert_response :success
    assert_select "a[href='#{proposal_path(proposals(:pending_proposal))}']", text: /Ver Detalhes/
  end
end
