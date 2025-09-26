class Message < ApplicationRecord
  belongs_to :mentorship_request
  belongs_to :user

  validates :body, presence: true

  after_create_commit do
    stream = "mentorship_request_#{mentorship_request_id}_messages"
    Turbo::StreamsChannel.broadcast_append_later_to(
      stream,
      target: ActionView::RecordIdentifier.dom_id(mentorship_request, :messages),
      partial: "messages/message",
      locals: { message: self }
    )
  end
end
