class Proposal < ApplicationRecord
  belongs_to :student, class_name: 'User'
  belongs_to :teacher, class_name: 'User'
  belongs_to :subject
  belongs_to :sender, class_name: 'User'

  has_many :messages, dependent: :destroy

  enum :status, pending: 0, accepted: 1, rejected: 2, closed: 3
  enum :modality, knowledge_pill: 0, express_session: 1, focused_mentoring: 2
  
  STATUS_NAMES = {
    "pending" => "Pendente",
    "accepted" => "Aceita",
    "rejected" => "Recusada",
    "closed" => "Fechada"
  }.freeze

  def status_human
    STATUS_NAMES[status] || status.humanize
  end
  
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :modality, presence: true
  validates :rating, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }, allow_nil: true
  validate :duration_respects_modality
  validate :price_respects_floor
  validate :users_have_correct_roles
  validate :users_are_different
  validate :sender_is_participant
  validate :users_are_not_banned
  validate :users_are_not_admins
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

  def synchronous?
    express_session? || focused_mentoring?
  end

  def asynchronous?
    knowledge_pill?
  end

  # Monetization
  def platform_fee_percentage
    0.20 # 20% platform fee
  end

  def platform_fee
    (price * platform_fee_percentage).round(2)
  end

  def teacher_receives
    price - platform_fee
  end

  private

  def duration_respects_modality
    case modality
    when "knowledge_pill"
      errors.add(:duration, "não deve ser preenchida para pílula de conhecimento") if duration.present?
    when "express_session"
      errors.add(:duration, "deve ser 15 minutos para sessão expressa") unless duration == 15
    when "focused_mentoring"
      errors.add(:duration, "deve ser 30, 45 ou 60 minutos para mentoria focada") unless [30, 45, 60].include?(duration)
    end
  end

  def price_respects_floor
    if price.to_f <= 0.0
      if modality == "knowledge_pill"
        return # Permitido tentar gratuitamente
      else
        errors.add(:price, "deve ser maior que zero para esta modalidade")
        return
      end
    end

    return unless teacher&.technical? || teacher&.higher?
    
    min_price = case modality
                when "knowledge_pill", "express_session"
                  15.0
                else
                  50.0
                end

    if price.to_f < min_price
      formatted_min_price = ('%.2f' % min_price).gsub('.', ',')
      errors.add(:price, "deve ser no mínimo R$ #{formatted_min_price} para professores certificados nesta modalidade")
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

  def users_are_not_banned
    errors.add(:student, "está banido e não pode participar de propostas") if student&.banned?
    errors.add(:teacher, "está banido e não pode participar de propostas") if teacher&.banned?
  end

  def users_are_not_admins
    errors.add(:student, "com perfil de administrador não pode participar de propostas") if student&.admin?
    errors.add(:teacher, "com perfil de administrador não pode participar de propostas") if teacher&.admin?
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
