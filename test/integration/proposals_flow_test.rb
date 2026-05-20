require "test_helper"

class ProposalsFlowTest < ActionDispatch::IntegrationTest
  setup do
    @student = users(:student)
    @teacher = users(:teacher)
    @subject = subjects(:math)
  end

  # ── Student sending proposal to teacher ──

  test "student can create a proposal and lands on negotiation page" do
    post login_path, params: { email: @student.email, password: "senha123" }

    # Use a new subject to avoid uniqueness conflict with pending_proposal fixture
    new_subject = Subject.create!(name: "Física")
    
    get new_proposal_path(teacher_id: @teacher.id)
    assert_response :success

    proposal = nil
    assert_difference('Proposal.count', 1) do
      post proposals_path, params: { proposal: { teacher_id: @teacher.id, subject_id: new_subject.id, price: 60.0, modality: "focused_mentoring", duration: 60 } }
      proposal = Proposal.last
    end

    # Verifies sender is set to the student
    assert_equal @student.id, proposal.sender_id
    assert_equal @student.id, proposal.student_id
    assert_equal @teacher.id, proposal.teacher_id

    assert_redirected_to proposal_path(proposal)
    follow_redirect!
    assert_response :success
    assert_select "h1", text: /Proposta:/
  end

  test "student-created proposal is persisted with correct fields" do
    post login_path, params: { email: @student.email, password: "senha123" }
    new_subject = Subject.create!(name: "Química")

    post proposals_path, params: { proposal: { teacher_id: @teacher.id, subject_id: new_subject.id, price: 75.0, modality: "focused_mentoring", duration: 60 } }
    proposal = Proposal.last

    assert_equal @student.id, proposal.student_id
    assert_equal @teacher.id, proposal.teacher_id
    assert_equal @student.id, proposal.sender_id
    assert_equal new_subject.id, proposal.subject_id
    assert_equal 75.0, proposal.price.to_f
    assert proposal.pending?
  end

  # ── Teacher sending proposal to student ──

  test "teacher can create a proposal for a student" do
    post login_path, params: { email: @teacher.email, password: "senha123" }

    other_student = User.create!(name: "Aluno Novo", email: "novo@aluno.com", password: "senha123", role: "student", phone: "11999999999", cpf: "11111111111")
    other_student.subjects << subjects(:programming)
    new_subject = subjects(:programming)

    get new_proposal_path(student_id: other_student.id)
    assert_response :success

    proposal = nil
    assert_difference('Proposal.count', 1) do
      post proposals_path, params: { proposal: { student_id: other_student.id, subject_id: new_subject.id, price: 80.0, modality: "focused_mentoring", duration: 60 } }
      proposal = Proposal.last
    end

    # Verifies sender is set to the teacher
    assert_equal @teacher.id, proposal.sender_id
    assert_equal @teacher.id, proposal.teacher_id
    assert_equal other_student.id, proposal.student_id

    assert_redirected_to proposal_path(proposal)
    follow_redirect!
    assert_response :success
    assert_select "h1", text: /Proposta:/
  end

  test "teacher-created proposal is persisted with correct fields" do
    post login_path, params: { email: @teacher.email, password: "senha123" }
    other_student = User.create!(name: "Aluno Persist", email: "persist@aluno.com", password: "senha123", role: "student", phone: "11988888888", cpf: "22222222222")
    
    post proposals_path, params: { proposal: { student_id: other_student.id, subject_id: @subject.id, price: 90.0, modality: "focused_mentoring", duration: 60 } }
    proposal = Proposal.last

    assert_equal other_student.id, proposal.student_id
    assert_equal @teacher.id, proposal.teacher_id
    assert_equal @teacher.id, proposal.sender_id
    assert_equal @subject.id, proposal.subject_id
    assert_equal 90.0, proposal.price.to_f
    assert proposal.pending?
  end

  # ── Accept/Reject: Recipient-based ──

  test "teacher (recipient) can accept a student-sent proposal" do
    post login_path, params: { email: @teacher.email, password: "senha123" }
    proposal = proposals(:pending_proposal) # sender is student

    patch accept_proposal_path(proposal)
    assert_redirected_to proposal_path(proposal)
    assert proposal.reload.accepted?
  end

  test "student (recipient) can accept a teacher-sent proposal" do
    other_student = User.create!(name: "Aluno Accept", email: "accept@aluno.com", password: "senha123", role: "student", phone: "11999999999", cpf: "11111111111")
    proposal = Proposal.create!(student: other_student, teacher: @teacher, subject: @subject, price: 60.0, sender: @teacher, modality: :focused_mentoring, duration: 60)

    post login_path, params: { email: other_student.email, password: "senha123" }
    patch accept_proposal_path(proposal)
    assert_redirected_to proposal_path(proposal)
    assert proposal.reload.accepted?
  end

  test "sender cannot accept their own proposal" do
    post login_path, params: { email: @student.email, password: "senha123" }
    proposal = proposals(:pending_proposal) # sender is student

    patch accept_proposal_path(proposal)
    assert_redirected_to proposal_path(proposal)
    assert proposal.reload.pending? # Status should NOT change
    assert_equal "Ação não permitida.", flash[:alert]
  end

  test "teacher (recipient) can reject a proposal" do
    post login_path, params: { email: @teacher.email, password: "senha123" }
    proposal = proposals(:pending_proposal)

    patch reject_proposal_path(proposal)
    assert_redirected_to proposal_path(proposal)
    assert proposal.reload.rejected?
  end

  test "student (recipient) can reject a teacher-sent proposal" do
    other_student = User.create!(name: "Aluno Reject", email: "reject@aluno.com", password: "senha123", role: "student", phone: "11988888888", cpf: "22222222222")
    proposal = Proposal.create!(student: other_student, teacher: @teacher, subject: @subject, price: 60.0, sender: @teacher, modality: :focused_mentoring, duration: 60)

    post login_path, params: { email: other_student.email, password: "senha123" }
    patch reject_proposal_path(proposal)
    assert_redirected_to proposal_path(proposal)
    assert proposal.reload.rejected?
  end

  # ── Close ──

  test "participants can close an accepted proposal" do
    post login_path, params: { email: @teacher.email, password: "senha123" }
    proposal = proposals(:pending_proposal)
    proposal.update_column(:status, 1) # accepted

    patch close_proposal_path(proposal)
    assert_redirected_to proposal_path(proposal)
    assert proposal.reload.closed?
  end

  # ── Chat ──

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

  # ── Access Control ──

  test "unauthorized user cannot access the proposal" do
    other_teacher = User.create!(name: "Outro Prof", email: "outro@prof.com", password: "pw", role: "teacher", education_level: "technical", certificate_url: "link", phone: "11977777777", cpf: "33333333333")
    post login_path, params: { email: other_teacher.email, password: "pw" }
    
    proposal = proposals(:pending_proposal)
    get proposal_path(proposal)
    
    assert_redirected_to root_path
    assert_equal "Proposta não encontrada ou acesso negado.", flash[:alert]
  end

  # ── View Rendering ──

  test "proposal show renders negotiation elements" do
    post login_path, params: { email: @student.email, password: "senha123" }
    proposal = proposals(:pending_proposal)

    get proposal_path(proposal)
    assert_response :success
    assert_select "h1", text: /Proposta:/
    assert_select "span", text: /Aluno:/
    assert_select "span", text: /Professor:/
    assert_select "span", text: /Valor:/
    assert_select "textarea" # Message form
  end

  test "recipient sees accept/reject buttons on pending proposal" do
    # pending_proposal sender is student, so teacher is the recipient
    post login_path, params: { email: @teacher.email, password: "senha123" }
    proposal = proposals(:pending_proposal)

    get proposal_path(proposal)
    assert_response :success
    assert_select "button", text: "Aceitar Proposta"
    assert_select "button", text: "Recusar"
  end

  test "sender sees waiting message on pending proposal" do
    # pending_proposal sender is student
    post login_path, params: { email: @student.email, password: "senha123" }
    proposal = proposals(:pending_proposal)

    get proposal_path(proposal)
    assert_response :success
    assert_select "button", text: "Aceitar Proposta", count: 0
    assert_select "div", text: /Aguardando resposta/
  end

  # ── Panel Visibility ──

  test "student panel shows all proposals including teacher-sent" do
    # Create a proposal sent by the teacher to this student
    Proposal.create!(student: @student, teacher: @teacher, subject: subjects(:programming), price: 70.0, sender: @teacher, modality: :focused_mentoring, duration: 60)

    post login_path, params: { email: @student.email, password: "senha123" }
    get student_path(@student)
    assert_response :success

    # Should see both proposals (fixture + new one)
    assert_select "a", text: /Ver Detalhes/, minimum: 2
    assert_select "span", text: /Recebida do professor/, count: 1
    assert_select "span", text: /Enviada por você/, count: 1
  end

  test "teacher panel shows all proposals including teacher-sent" do
    post login_path, params: { email: @teacher.email, password: "senha123" }
    get teacher_path(@teacher)
    assert_response :success
    assert_select "a[href='#{proposal_path(proposals(:pending_proposal))}']", text: /Ver Detalhes/
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

  # ── Contra-propostas ──

  test "student can counter-propose to teacher" do
    # pending_proposal was sent by student to teacher, so teacher is recipient
    # Let's make teacher the sender and student the recipient by creating a new proposal where sender is teacher
    new_subject = subjects(:programming)
    proposal = Proposal.create!(student: @student, teacher: @teacher, subject: new_subject, price: 80.0, sender: @teacher, status: :pending, modality: :focused_mentoring, duration: 60)

    post login_path, params: { email: @student.email, password: "senha123" }

    # Student is recipient, should see "Contra-propor novo valor" form
    get proposal_path(proposal)
    assert_response :success
    assert_select "summary", text: /Contra-propor novo valor/

    assert_difference 'proposal.messages.count', 1 do
      patch counter_proposal_path(proposal), params: { price: "70,00" }
    end

    proposal.reload
    assert_equal 70.0, proposal.price.to_f
    assert_equal @student.id, proposal.sender_id
    assert_equal @teacher.id, proposal.recipient.id # recipient inverted to teacher
    assert proposal.pending?

    assert_redirected_to proposal_path(proposal)
    follow_redirect!
    assert_match "Contra-proposta enviada com sucesso!", response.body
    assert_match /Fez uma contra-proposta de (R\$|\$)\s*70[.,]00/, response.body
  end

  test "teacher can counter-propose to student" do
    # pending_proposal was sent by student to teacher, so teacher is recipient
    proposal = proposals(:pending_proposal)

    post login_path, params: { email: @teacher.email, password: "senha123" }

    get proposal_path(proposal)
    assert_response :success
    assert_select "summary", text: /Contra-propor novo valor/

    assert_difference 'proposal.messages.count', 1 do
      patch counter_proposal_path(proposal), params: { price: "90,00" }
    end

    proposal.reload
    assert_equal 90.0, proposal.price.to_f
    assert_equal @teacher.id, proposal.sender_id
    assert_equal @student.id, proposal.recipient.id # recipient inverted to student
    assert proposal.pending?

    assert_redirected_to proposal_path(proposal)
    follow_redirect!
    assert_match "Contra-proposta enviada com sucesso!", response.body
    assert_match /Fez uma contra-proposta de (R\$|\$)\s*90[.,]00/, response.body
  end

  test "unauthorized user cannot counter-propose" do
    proposal = proposals(:pending_proposal)
    other_teacher = User.create!(name: "Outro Prof", email: "outro@prof.com", password: "pw", role: "teacher", education_level: "technical", certificate_url: "link", phone: "11977777777", cpf: "33333333333")

    post login_path, params: { email: other_teacher.email, password: "pw" }

    # Unauthorized access (not participant)
    patch counter_proposal_path(proposal), params: { price: "80,00" }
    assert_redirected_to root_path
    assert_equal "Proposta não encontrada ou acesso negado.", flash[:alert]
  end

  test "sender cannot counter-propose to their own pending proposal" do
    # pending_proposal sender is student
    proposal = proposals(:pending_proposal)

    post login_path, params: { email: @student.email, password: "senha123" }

    patch counter_proposal_path(proposal), params: { price: "50,00" }
    assert_redirected_to proposal_path(proposal)
    assert_equal "Acesso não autorizado.", flash[:alert]
  end

  test "counter-proposal does not block price below recommended floor" do
    # pending_proposal was sent by student to @teacher (education_level: technical)
    proposal = proposals(:pending_proposal)

    post login_path, params: { email: @teacher.email, password: "senha123" }

    # Try to counter-propose R$ 40,00 (below recommendation of 50.0)
    patch counter_proposal_path(proposal), params: { price: "40,00" }
    assert_redirected_to proposal_path(proposal)
    follow_redirect!
    assert_equal 40.0, proposal.reload.price.to_f
    assert_match "Contra-proposta enviada com sucesso!", response.body
  end

  test "student can create a short mentoring proposal and price recommendation is calculated" do
    post login_path, params: { email: @student.email, password: "senha123" }

    new_subject = Subject.create!(name: "Astronomia")
    
    assert_difference('Proposal.count', 1) do
      post proposals_path, params: { 
        proposal: { 
          teacher_id: @teacher.id, 
          subject_id: new_subject.id, 
          price: "35,00", 
          modality: "focused_mentoring", 
          duration: 45 
        } 
      }
    end

    proposal = Proposal.last
    assert_equal 45, proposal.duration
    assert_equal 35.0, proposal.price.to_f
    assert_equal 37.50, proposal.recommended_price
    assert_equal "45 minutos", proposal.duration_human

    assert_redirected_to proposal_path(proposal)
    follow_redirect!
    assert_response :success
    assert_select "span", text: /45 minutos/
  end
end
