require "test_helper"

class ProposalTest < ActiveSupport::TestCase
  test "price below recommended floor is valid for technical teacher" do
    teacher = users(:teacher) # education_level: 1 (technical)
    proposal = Proposal.new(student: users(:student), teacher: teacher, subject: subjects(:programming), price: 40.0, sender: users(:student), modality: :focused_mentoring, duration: 60)
    
    assert proposal.valid?
    assert proposal.has_recommended_price?
    assert_equal 50.0, proposal.recommended_price
  end

  test "price lower than floor allowed for basic education teacher" do
    basic_teacher = User.create!(name: "Basic", email: "b@t.com", password: "pw", role: :teacher, education_level: :basic, certificate_url: "link", phone: "11999999999", cpf: "12345678901")
    proposal = Proposal.new(student: users(:student), teacher: basic_teacher, subject: subjects(:math), price: 30.0, sender: users(:student), modality: :focused_mentoring, duration: 60)
    assert proposal.valid?
  end

  test "users must have correct roles" do
    proposal = Proposal.new(student: users(:teacher), teacher: users(:student), subject: subjects(:math), price: 60.0, modality: :focused_mentoring, duration: 60)
    assert_not proposal.valid?
    assert_includes proposal.errors[:student].join, "deve ter perfil de aluno"
    assert_includes proposal.errors[:teacher].join, "deve ter perfil de professor"
  end

  test "cannot send proposal to self" do
    student = users(:student)
    # temporarily bypass role for testing self
    proposal = Proposal.new(student: student, teacher: student, subject: subjects(:math), price: 60.0, modality: :focused_mentoring, duration: 60)
    assert_not proposal.valid?
    assert_includes proposal.errors[:base].join, "Você não pode enviar uma proposta para si mesmo"
  end

  test "duplicity is not allowed for pending or accepted proposals" do
    # pending_proposal já existe (math, teacher, student) status: pending
    dup_proposal = Proposal.new(student: users(:student), teacher: users(:teacher), subject: subjects(:math), price: 70.0, modality: :focused_mentoring, duration: 60)
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

  test "express_session modality is no longer valid" do
    proposal = Proposal.new(student: users(:student), teacher: users(:teacher), subject: subjects(:programming), price: 60.0, sender: users(:student), modality: :express_session, duration: 15)
    assert_not proposal.valid?
    assert_includes proposal.errors[:modality].join, "Expressa não é mais uma modalidade ativa"
  end

  test "focused_mentoring requires duration in minutes" do
    proposal = Proposal.new(student: users(:student), teacher: users(:teacher), subject: subjects(:programming), price: 60.0, sender: users(:student), modality: :focused_mentoring, duration: nil)
    assert_not proposal.valid?
    assert_includes proposal.errors[:duration].join, "deve ser informada para mentoria focada"

    proposal.duration = 0
    assert_not proposal.valid?
    assert_includes proposal.errors[:duration].join, "não pode ser zero"

    proposal.duration = 120
    proposal.price = 100.0
    assert proposal.valid?
  end

  test "price does not block submission below recommended floor but exposes recommendation" do
    teacher = users(:teacher)
    proposal = Proposal.new(student: users(:student), teacher: teacher, subject: subjects(:programming), price: 90.0, sender: users(:student), modality: :focused_mentoring, duration: 120)
    assert proposal.valid?
    assert proposal.has_recommended_price?
    assert_equal 100.0, proposal.recommended_price
  end

  test "mentoring with less than 1 hour is valid and calculates recommended price correctly" do
    teacher = users(:teacher)
    
    # 30 minutes
    prop_30 = Proposal.new(student: users(:student), teacher: teacher, subject: subjects(:programming), price: 25.0, sender: users(:student), modality: :focused_mentoring, duration: 30)
    assert prop_30.valid?
    assert_equal 25.0, prop_30.recommended_price
    assert_equal "30 minutos", prop_30.duration_human

    # 45 minutes
    prop_45 = Proposal.new(student: users(:student), teacher: teacher, subject: subjects(:programming), price: 37.50, sender: users(:student), modality: :focused_mentoring, duration: 45)
    assert prop_45.valid?
    assert_equal 37.50, prop_45.recommended_price
    assert_equal "45 minutos", prop_45.duration_human

    # 1h 30m (90 minutes)
    prop_90 = Proposal.new(student: users(:student), teacher: teacher, subject: subjects(:programming), price: 75.0, sender: users(:student), modality: :focused_mentoring, duration: 90)
    assert prop_90.valid?
    assert_equal 75.0, prop_90.recommended_price
    assert_equal "1 hora e 30 minutos", prop_90.duration_human
  end
end
