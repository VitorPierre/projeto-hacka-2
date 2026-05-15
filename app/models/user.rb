class User < ApplicationRecord
  has_secure_password
  
  has_and_belongs_to_many :subjects
  has_many :sent_proposals, class_name: 'Proposal', foreign_key: 'student_id'
  has_many :received_proposals, class_name: 'Proposal', foreign_key: 'teacher_id'

  enum :role, student: 0, teacher: 1
  enum :education_level, basic: 0, technical: 1, higher: 2

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :certificate_url, presence: true, if: :teacher?

  scope :certified_teachers, -> { teacher.where(certified: true) }
end
