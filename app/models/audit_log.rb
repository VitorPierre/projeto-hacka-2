class AuditLog < ApplicationRecord
  belongs_to :admin, class_name: 'User', optional: true
  belongs_to :target, class_name: 'User', optional: true

  validates :action, presence: true
  validates :details, presence: true
end
