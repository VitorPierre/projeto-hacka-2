class Proposal < ApplicationRecord
  belongs_to :student, class_name: 'User'
  belongs_to :teacher, class_name: 'User'
  belongs_to :subject
  belongs_to :sender, class_name: 'User'

  has_many :messages, dependent: :destroy

  enum :status, pending: 0, accepted: 1, rejected: 2, closed: 3
  
  STATUS_NAMES = {
    "pending" => "Pendente",
    "accepted" => "Aceita",
    "rejected" => "Recusada",
    "closed" => "Fechada"
  }.freeze

  def status_human
    STATUS_NAMES[status] || status.humanize
  end
  
  validates :price, presence: true, numericality: { greater_than: 0 }
  validate :price_respects_floor
  validate :users_have_correct_roles
  validate :users_are_different
  validate :sender_is_participant
  validate :valid_status_transition, on: :update

  validates :subject_id, uniqueness: { 
    scope: [:student_id, :teacher_id], 
    conditions: -> { where(status: [:pending, :accepted]) }, 
    message: "já possui uma proposta em andamento com este professor para esta matéria" 
  }

  # Returns the user who should decide on the proposal (the one who did NOT send it)
  def recipient
    sender_id == student_id ? teacher : student
  end

  # Returns the user who initiated the proposal
  def sender_user
    sender_id == student_id ? student : teacher
  end

  # Check if a given user is the recipient of this proposal
  def recipient?(user)
    recipient.id == user.id
  end

  private

  def price_respects_floor
    return unless teacher&.technical? || teacher&.higher?
    if price.to_f < 50.0
      errors.add(:price, "deve ser no mínimo R$ 50,00 para professores de nível técnico ou superior")
    end
  end

  def users_have_correct_roles
    errors.add(:student, "deve ter perfil de aluno") unless student&.student?
    errors.add(:teacher, "deve ter perfil de professor") unless teacher&.teacher?
  end

  def users_are_different
    if student_id == teacher_id && student_id.present?
      errors.add(:base, "Você não pode enviar uma proposta para si mesmo")
    end
  end

  def sender_is_participant
    return unless sender_id.present?
    unless sender_id == student_id || sender_id == teacher_id
      errors.add(:sender, "deve ser o aluno ou o professor da proposta")
    end
  end

  def valid_status_transition
    if status_changed?
      old_status = status_was
      new_status = status

      case old_status
      when 'pending'
        unless %w[accepted rejected].include?(new_status)
          errors.add(:status, "inválido a partir de pendente")
        end
      when 'accepted'
        unless new_status == 'closed'
          errors.add(:status, "inválido a partir de aceita")
        end
      when 'rejected', 'closed'
        errors.add(:status, "não pode ser alterado após ser #{old_status}")
      end
    end
  end
end
