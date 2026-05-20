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
  enum :status, active: 0, suspended: 1, banned: 2
  enum :moderation_status, unreviewed: 0, flagged_suspicious: 1, reviewed_safe: 2

  def suspicious?
    return false if reviewed_safe?
    ModerationService.inappropriate?(name) ||
      ModerationService.inappropriate?(availability) ||
      ModerationService.inappropriate?(experience) ||
      ModerationService.inappropriate?(preferences)
  end

  def self.suspicious
    all.select(&:suspicious?)
  end

  EDUCATION_LEVEL_NAMES = {
    "basic" => "Médio",
    "technical" => "Técnico",
    "higher" => "Bacharel"
  }.freeze

  def education_level_human
    EDUCATION_LEVEL_NAMES[education_level] || "Não informado"
  end

  CURRENT_TERMS_VERSION = "1.0"
  CURRENT_PRIVACY_VERSION = "1.0"

  def accepted_current_terms_and_privacy?
    terms_accepted_version == CURRENT_TERMS_VERSION && privacy_accepted_version == CURRENT_PRIVACY_VERSION
  end

  before_validation :normalize_cpf_and_phone
  before_create :record_terms_acceptance

  validates :terms_acceptance, acceptance: { message: "deve ser aceito para prosseguir" }, on: :create
  validates :name, presence: { message: "não pode ficar em branco" }, inappropriate_text: true, if: :name_changed?
  validates :email, presence: { message: "não pode ficar em branco" }
  validates :email, uniqueness: { message: "já está cadastrado em outra conta" }, if: :email_changed?
  validates :phone, presence: { message: "não pode ficar em branco" }
  validates :cpf, presence: { message: "não pode ficar em branco" }
  validates :cpf, uniqueness: { message: "já está cadastrado em outra conta" }, if: :cpf_changed?
  validates :certificate_url, presence: { message: "não pode ficar em branco" }, if: :teacher?
  validates :availability, inappropriate_text: true, if: :availability_changed?
  validates :experience, inappropriate_text: true, if: :experience_changed?
  validates :preferences, inappropriate_text: true, if: :preferences_changed?
  validate :valid_presentation_video_url, if: -> { teacher? && presentation_video_url.present? }

  def youtube_video_id
    return nil if presentation_video_url.blank?
    
    require 'cgi'
    uri = URI.parse(presentation_video_url.strip) rescue nil
    return nil unless uri
    
    if uri.host&.include?("youtu.be")
      uri.path.delete_prefix("/")
    elsif uri.host&.include?("youtube.com")
      if uri.path.include?("/embed/")
        uri.path.split("/embed/").last&.split("?")&.first
      elsif uri.path.include?("/shorts/")
        uri.path.split("/shorts/").last&.split("?")&.first
      else
        params = CGI.parse(uri.query || "")
        params["v"]&.first
      end
    end
  end

  private

  def record_terms_acceptance
    self.terms_accepted_version = CURRENT_TERMS_VERSION
    self.privacy_accepted_version = CURRENT_PRIVACY_VERSION
    self.terms_accepted_at = Time.current
  end

  def valid_presentation_video_url
    video_id = youtube_video_id
    if video_id.blank? || video_id.length != 11 || video_id !~ /\A[a-zA-Z0-9\-_]{11}\z/
      errors.add(:presentation_video_url, "deve ser um link válido do YouTube")
    end
  end

  def normalize_cpf_and_phone
    self.cpf = cpf.gsub(/\D/, "") if cpf.present?
    self.phone = phone.gsub(/\D/, "") if phone.present?
  end

  scope :public_view, -> { where.not(status: :banned).where(admin: false) }
  scope :certified_teachers, -> { teacher.public_view } # Showing all unbanned teachers for the hackathon flow
end
