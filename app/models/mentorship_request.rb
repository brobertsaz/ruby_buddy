class MentorshipRequest < ApplicationRecord
  belongs_to :mentee, class_name: "User"
  belongs_to :mentor, class_name: "User", optional: true

  enum :status, { open: 0, accepted: 1, closed: 2 }

  has_many :messages, dependent: :destroy
  has_many :conversation_metadata, class_name: 'ConversationMetadata', dependent: :destroy

  validates :topic, presence: true

  # Helper method to get unread message count for a specific user
  def unread_count_for_user(user)
    messages.where.not(user: user).unread.count
  end

  # Helper method to get typing users (excluding current user)
  def users_typing_except(current_user)
    conversation_metadata
      .typing_for_request(id)
      .where.not(user: current_user)
      .includes(:user)
      .map(&:user)
  end
end
