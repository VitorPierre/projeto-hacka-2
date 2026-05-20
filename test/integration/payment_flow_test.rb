require "test_helper"

class PaymentFlowTest < ActionDispatch::IntegrationTest
  setup do
    @student = users(:student)
    @teacher = users(:teacher)
    @subject = subjects(:math)
  end

  test "complete proposal lifecycle from creation to payment" do
    # 1. Login as Student
    post login_path, params: { email: @student.email, password: "senha123" }
    assert_redirected_to student_path(@student)
    follow_redirect!
    assert_response :success

    # 2. Create a new proposal
    new_subject = Subject.create!(name: "Física Quântica")
    assert_difference('Proposal.count', 1) do
      post proposals_path, params: { 
        proposal: { 
          teacher_id: @teacher.id, 
          subject_id: new_subject.id, 
          price: "60,00", 
          modality: "focused_mentoring", 
          duration: 60 
        } 
      }
    end
    proposal = Proposal.last
    assert_equal 60.0, proposal.price.to_f
    assert proposal.pending?

    # 3. Login as Teacher to accept and close the proposal
    delete logout_path
    post login_path, params: { email: @teacher.email, password: "senha123" }
    
    # Accept the proposal
    patch accept_proposal_path(proposal)
    assert_redirected_to proposal_path(proposal)
    proposal.reload
    assert proposal.accepted?

    # Close the proposal
    patch close_proposal_path(proposal)
    assert_redirected_to proposal_path(proposal)
    proposal.reload
    assert proposal.closed?
    assert_not proposal.paid?

    # 4. Login as Student to pay the proposal
    delete logout_path
    post login_path, params: { email: @student.email, password: "senha123" }

    # Pay the proposal (simulated Pix)
    patch pay_proposal_path(proposal)
    assert_redirected_to proposal_path(proposal)
    proposal.reload
    
    # Assertions
    assert proposal.paid?, "Proposal should be paid"
    assert_equal "Pagamento simulado com sucesso!", flash[:notice]
  end
end
