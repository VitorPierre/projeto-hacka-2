require "test_helper"

class ProposalTest < ActiveSupport::TestCase
  test "price respects floor for technical teacher" do
    teacher = users(:teacher) # education_level: 1 (technical)
    proposal = Proposal.new(student: users(:student), teacher: teacher, subject: subjects(:programming), price: 40.0, sender: users(:student))
    
    assert_not proposal.valid?
    assert_includes proposal.errors[:price].join, "deve ser no mínimo R$ 50,00"

    proposal.price = 55.0
    assert proposal.valid?
  end

  test "price lower than floor allowed for basic education teacher" do
    basic_teacher = User.create!(name: "Basic", email: "b@t.com", password: "pw", role: :teacher, education_level: :basic, certificate_url: "link", phone: "11999999999", cpf: "12345678901")
    proposal = Proposal.new(student: users(:student), teacher: basic_teacher, subject: subjects(:math), price: 30.0, sender: users(:student))
    assert proposal.valid?
  end

  test "users must have correct roles" do
    proposal = Proposal.new(student: users(:teacher), teacher: users(:student), subject: subjects(:math), price: 60.0)
    assert_not proposal.valid?
    assert_includes proposal.errors[:student].join, "deve ter perfil de aluno"
    assert_includes proposal.errors[:teacher].join, "deve ter perfil de professor"
  end

  test "cannot send proposal to self" do
    student = users(:student)
    # temporarily bypass role for testing self
    proposal = Proposal.new(student: student, teacher: student, subject: subjects(:math), price: 60.0)
    assert_not proposal.valid?
    assert_includes proposal.errors[:base].join, "Você não pode enviar uma proposta para si mesmo"
  end

  test "duplicity is not allowed for pending or accepted proposals" do
    # pending_proposal já existe (math, teacher, student) status: pending
    dup_proposal = Proposal.new(student: users(:student), teacher: users(:teacher), subject: subjects(:math), price: 70.0)
    assert_not dup_proposal.valid?
    assert_includes dup_proposal.errors[:subject_id].join, "já possui uma proposta em andamento"
  end

  test "valid status transition" do
    proposal = proposals(:pending_proposal)
    
    # pending -> closed (invalid)
    proposal.status = :closed
    assert_not proposal.valid?
    
    # pending -> accepted (valid)
    proposal.reload
    proposal.status = :accepted
    assert proposal.valid?

    # accepted -> rejected (invalid)
    proposal.save!
    proposal.status = :rejected
    assert_not proposal.valid?

    # accepted -> closed (valid)
    proposal.reload
    proposal.status = :closed
    assert proposal.valid?
  end
end
