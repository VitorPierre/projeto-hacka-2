class User < ApplicationRecord
  has_one_attached :avatar
  has_secure_password
  
  has_and_belongs_to_many :subjects
  has_many :proposals_as_student, class_name: 'Proposal', foreign_key: 'student_id'
  has_many :proposals_as_teacher, class_name: 'Proposal', foreign_key: 'teacher_id'
  has_many :initiated_proposals, class_name: 'Proposal', foreign_key: 'sender_id'
  has_many :notifications, dependent: :destroy
  # All proposals where this user is involved (as student or teacher)
  def all_proposals
    Proposal.where("student_id = ? OR teacher_id = ?", id, id)
  end

  def average_rating
    proposals_as_teacher.average(:rating)&.round(1)
  end

  def ratings_count
    proposals_as_teacher.where.not(rating: nil).count
  end

  # Aliases for backward compatibility
  alias_method :sent_proposals, :proposals_as_student
  alias_method :received_proposals, :proposals_as_teacher

  enum :role, student: 0, teacher: 1
  enum :education_level, basic: 0, technical: 1, higher: 2

  EDUCATION_LEVEL_NAMES = {
    "basic" => "Médio",
    "technical" => "Técnico",
    "higher" => "Bacharel"
  }.freeze

  def education_level_human
    EDUCATION_LEVEL_NAMES[education_level] || "Não informado"
  end

  before_validation :normalize_cpf_and_phone

  validates :name, presence: { message: "não pode ficar em branco" }
  validates :email, presence: { message: "não pode ficar em branco" }
  validates :email, uniqueness: { message: "já está cadastrado em outra conta" }, if: :email_changed?
  validates :phone, presence: { message: "não pode ficar em branco" }
  validates :cpf, presence: { message: "não pode ficar em branco" }
  validates :cpf, uniqueness: { message: "já está cadastrado em outra conta" }, if: :cpf_changed?
  validates :certificate_url, presence: { message: "não pode ficar em branco" }, if: :teacher?

  private

  def normalize_cpf_and_phone
    self.cpf = cpf.gsub(/\D/, "") if cpf.present?
    self.phone = phone.gsub(/\D/, "") if phone.present?
  end

  scope :certified_teachers, -> { teacher } # Showing all teachers for the hackathon flow
end
