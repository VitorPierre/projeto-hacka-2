class Notification < ApplicationRecord
  belongs_to :user

  validates :message, presence: true

  scope :unread, -> { where(read_at: nil) }
  scope :recent, -> { order(created_at: :desc) }

  def mark_as_read!
    update(read_at: Time.current)
  end
end
