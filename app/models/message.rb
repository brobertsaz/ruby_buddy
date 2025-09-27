class Message < ApplicationRecord
  belongs_to :mentorship_request
  belongs_to :user

  validates :body, presence: true

  # Set sent_at timestamp when message is created
  before_create :set_sent_at

  # Scopes for message status
  scope :sent, -> { where.not(sent_at: nil) }
  scope :read, -> { where.not(read_at: nil) }
  scope :unread, -> { where(read_at: nil) }

  # Scope for unread messages in a specific mentorship request
  scope :unread_for_request, ->(request_id) { unread.where(mentorship_request_id: request_id) }

  # Class method for counting unread messages in a request
  def self.unread_count_for_request(request_id)
    unread_for_request(request_id).count
  end

  # Instance methods for status checking
  def sent?
    sent_at.present?
  end

  def read?
    read_at.present?
  end

  def unread?
    !read?
  end

  # Method to mark message as read
  def mark_as_read!
    update!(read_at: Time.current) unless read?
  end

  after_create_commit do
    stream = "mentorship_request_#{mentorship_request_id}_messages"
    Turbo::StreamsChannel.broadcast_append_later_to(
      stream,
      target: ActionView::RecordIdentifier.dom_id(mentorship_request, :messages),
      partial: "messages/message",
      locals: { message: self }
    )
  end

  private

  def set_sent_at
    self.sent_at = Time.current unless sent_at.present?
  end
end
