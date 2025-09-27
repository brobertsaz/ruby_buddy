class ConversationMetadata < ApplicationRecord
  self.table_name = 'conversation_metadata'

  belongs_to :mentorship_request
  belongs_to :user

  validates :typing, inclusion: { in: [true, false] }

  before_update :update_typing_timestamp, if: :typing_changed?

  scope :typing_for_request, ->(request_id) { where(mentorship_request_id: request_id, typing: true) }

  def self.find_or_initialize_for_user_and_request(user, mentorship_request)
    find_or_initialize_by(user: user, mentorship_request: mentorship_request)
  end

  def self.cleanup_expired_typing_indicators(timeout = 5.seconds)
    where(typing: true)
      .where('typing_updated_at < ?', timeout.ago)
      .update_all(typing: false)
  end

  private

  def update_typing_timestamp
    self.typing_updated_at = Time.current
  end
end
