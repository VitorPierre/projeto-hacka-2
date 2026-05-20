class Proposal < ApplicationRecord
  belongs_to :student, class_name: 'User'
  belongs_to :teacher, class_name: 'User'
  belongs_to :subject
  belongs_to :sender, class_name: 'User'

  has_many :messages, dependent: :destroy
  has_one_attached :videoaula

  enum :status, pending: 0, accepted: 1, rejected: 2, closed: 3
  enum :modality, knowledge_pill: 0, express_session: 1, focused_mentoring: 2
  
  MODALITY_NAMES = {
    "knowledge_pill" => "Pílula de Conhecimento",
    "express_session" => "Sessão Expressa",
    "focused_mentoring" => "Mentoria Focada"
  }.freeze

  def modality_human
    MODALITY_NAMES[modality] || modality.to_s.humanize
  end

  def duration_human
    return "" if duration.blank?
    
    hours = duration / 60
    minutes = duration % 60
    
    parts = []
    if hours > 0
      parts << "#{hours} #{hours == 1 ? 'hora' : 'horas'}"
    end
    if minutes > 0
      parts << "#{minutes} #{minutes == 1 ? 'minuto' : 'minutos'}"
    end
    
    parts.join(" e ")
  end

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
  validate :student_must_be_sender, on: :create
  validate :valid_status_transition, on: :update
  validate :videoaula_content_type_and_size

  validates :subject_id, uniqueness: { 
    scope: [:student_id, :teacher_id], 
    conditions: -> { where(status: [:pending, :accepted]) }, 
    message: "já possui uma proposta em andamento com este professor para esta matéria" 
  }, if: -> { pending? || accepted? }

  before_validation :set_default_modality

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
    focused_mentoring?
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

  def recommended_price
    return 0.0 unless has_recommended_price?

    case modality
    when "knowledge_pill"
      15.0
    when "focused_mentoring"
      ((50.0 / 60.0) * (duration || 60).to_f).round(2)
    else
      15.0
    end
  end

  def has_recommended_price?
    teacher&.technical? || teacher&.higher?
  end

  private

  def set_default_modality
    if modality.blank?
      self.modality = :focused_mentoring
      self.duration ||= 60
    end
  end

  def duration_respects_modality
    case modality
    when "knowledge_pill"
      errors.add(:duration, "não deve ser preenchida para pílula de conhecimento") if duration.present?
    when "focused_mentoring"
      errors.add(:duration, "deve ser informada para mentoria focada") if duration.blank?
      errors.add(:duration, "não pode ser zero") if duration.present? && duration.to_i <= 0
    when "express_session"
      errors.add(:modality, "Expressa não é mais uma modalidade ativa")
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

  def videoaula_content_type_and_size
    return unless videoaula.attached?

    unless videoaula.content_type.in?(%w[video/mp4 video/webm video/quicktime video/ogg video/x-matroska])
      errors.add(:videoaula, "deve ser um arquivo de vídeo válido (MP4, WebM, MOV, OGG, MKV)")
    end

    if videoaula.byte_size > 100.megabytes
      errors.add(:videoaula, "deve ter tamanho inferior a 100 MB")
    end
  end

  def student_must_be_sender
    if sender_id.present? && sender_id != student_id
      errors.add(:sender, "Apenas o aluno pode iniciar uma proposta.")
    end
  end
end
