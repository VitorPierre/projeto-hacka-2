class Message < ApplicationRecord
  belongs_to :proposal
  belongs_to :user

  has_one_attached :attachment

  enum :message_type, regular: 0, activity: 1
  enum :question_type, open: 0, closed: 1

  validates :content, presence: true, unless: -> { attachment.attached? }
  validates :options, presence: true, if: -> { activity? && closed? }

  after_create_commit -> { broadcast_append_to proposal, target: "messages" }
  after_update_commit -> { broadcast_replace_to proposal }

  def parsed_options
    return [] if options.blank?
    options.split("\n").map(&:strip).reject(&:blank?)
  end
end
