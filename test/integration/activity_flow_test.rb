require "test_helper"

class ActivityFlowTest < ActionDispatch::IntegrationTest
  setup do
    @student = users(:student)
    @teacher = users(:teacher)
    @proposal = proposals(:pending_proposal)
    @proposal.update_column(:status, 1) # Set to accepted so that all chat and video features are fully active
  end

  test "teacher can create an open activity and student can view and answer it" do
    # 1. Login as teacher and create open activity
    post login_path, params: { email: @teacher.email, password: "senha123" }
    
    assert_difference('Message.count', 1) do
      post proposal_messages_path(@proposal), params: {
        message: {
          content: "Qual é a raiz quadrada de 144?",
          message_type: "activity",
          question_type: "open"
        }
      }
    end

    activity = Message.last
    assert_equal "activity", activity.message_type
    assert_equal "open", activity.question_type
    assert_nil activity.student_answer

    # 2. Login as student and verify they see it and can answer it
    delete logout_path
    post login_path, params: { email: @student.email, password: "senha123" }

    get proposal_path(@proposal)
    assert_response :success
    assert_select "form[action=?]", answer_proposal_message_path(@proposal, activity)

    # Answer the activity
    patch answer_proposal_message_path(@proposal, activity), params: { student_answer: "12" }
    assert_redirected_to proposal_path(@proposal)
    
    activity.reload
    assert_equal "12", activity.student_answer

    # Verify that they see their own answer and form is gone
    follow_redirect!
    assert_select "p", text: /"12"/
    assert_select "form[action=?]", answer_proposal_message_path(@proposal, activity), count: 0
  end

  test "teacher can create a closed activity and student can answer it" do
    # 1. Login as teacher and create closed activity
    post login_path, params: { email: @teacher.email, password: "senha123" }
    
    assert_difference('Message.count', 1) do
      post proposal_messages_path(@proposal), params: {
        message: {
          content: "Quanto é 5 + 7?",
          message_type: "activity",
          question_type: "closed",
          options: "10\n12\n14\n16"
        }
      }
    end

    activity = Message.last
    assert_equal "activity", activity.message_type
    assert_equal "closed", activity.question_type
    assert_equal ["10", "12", "14", "16"], activity.parsed_options
    assert_nil activity.student_answer

    # 2. Login as student and answer it
    delete logout_path
    post login_path, params: { email: @student.email, password: "senha123" }

    patch answer_proposal_message_path(@proposal, activity), params: { student_answer: "12" }
    assert_redirected_to proposal_path(@proposal)
    
    activity.reload
    assert_equal "12", activity.student_answer
  end

  test "student cannot create activities" do
    # Login as student
    post login_path, params: { email: @student.email, password: "senha123" }

    assert_no_difference('Message.count') do
      post proposal_messages_path(@proposal), params: {
        message: {
          content: "Eu sou um aluno tentando criar atividade",
          message_type: "activity",
          question_type: "open"
        }
      }
    end

    assert_redirected_to proposal_path(@proposal)
    assert_equal "Apenas professores podem criar atividades.", flash[:alert]
  end

  test "student cannot answer the same activity twice" do
    # Create activity
    activity = Message.create!(
      proposal: @proposal,
      user: @teacher,
      content: "Qual a capital do Brasil?",
      message_type: "activity",
      question_type: "open"
    )

    # Login as student
    post login_path, params: { email: @student.email, password: "senha123" }

    # Answer for the first time
    patch answer_proposal_message_path(@proposal, activity), params: { student_answer: "Brasília" }
    assert_redirected_to proposal_path(@proposal)
    assert_equal "Brasília", activity.reload.student_answer

    # Try to answer for the second time
    patch answer_proposal_message_path(@proposal, activity), params: { student_answer: "Rio de Janeiro" }
    assert_redirected_to proposal_path(@proposal)
    assert_equal "Você já respondeu a esta atividade.", flash[:alert]
    assert_equal "Brasília", activity.reload.student_answer # Answer remained Brasília
  end

  test "unauthorized users cannot answer activities" do
    # Create activity
    activity = Message.create!(
      proposal: @proposal,
      user: @teacher,
      content: "Qual a capital do Brasil?",
      message_type: "activity",
      question_type: "open"
    )

    # Login as unauthorized user (e.g. uncertified teacher)
    other = users(:uncertified_teacher)
    post login_path, params: { email: other.email, password: "senha123" }

    patch answer_proposal_message_path(@proposal, activity), params: { student_answer: "Brasília" }
    assert_redirected_to root_path # Because of the proposal-level authorization inside messages_controller
    assert_nil activity.reload.student_answer
  end
end
