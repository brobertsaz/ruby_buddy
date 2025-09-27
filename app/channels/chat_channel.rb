class ChatChannel < ApplicationCable::Channel
  def subscribed
    mentorship_request = find_mentorship_request
    return reject unless mentorship_request

    unless authorized_for_mentorship_request?(mentorship_request)
      return reject
    end

    # Subscribe to message updates
    stream_from "mentorship_request_#{mentorship_request.id}_messages"

    # Subscribe to message status updates
    stream_from "mentorship_request_#{mentorship_request.id}_status"

    # Subscribe to typing indicators
    stream_from "mentorship_request_#{mentorship_request.id}_typing"

    # Clean up expired typing indicators when user connects
    ConversationMetadata.cleanup_expired_typing_indicators
  end

  def unsubscribed
    # Clean up typing status when user disconnects
    mentorship_request = find_mentorship_request
    if mentorship_request && current_user
      metadata = ConversationMetadata.find_by(
        user: current_user,
        mentorship_request: mentorship_request
      )

      if metadata&.typing?
        metadata.update(typing: false)
        broadcast_typing_update(metadata)
      end
    end
  end

  def start_typing(data)
    mentorship_request = find_mentorship_request
    return unless mentorship_request && authorized_for_mentorship_request?(mentorship_request)

    metadata = ConversationMetadata.find_or_initialize_for_user_and_request(
      current_user,
      mentorship_request
    )

    metadata.typing = true
    metadata.typing_updated_at = Time.current
    metadata.save!

    broadcast_typing_update(metadata)
  end

  def stop_typing(data)
    mentorship_request = find_mentorship_request
    return unless mentorship_request && authorized_for_mentorship_request?(mentorship_request)

    metadata = ConversationMetadata.find_by(
      user: current_user,
      mentorship_request: mentorship_request
    )

    if metadata&.typing?
      metadata.update(typing: false)
      broadcast_typing_update(metadata)
    end
  end

  def mark_message_read(data)
    message = Message.find_by(id: data['message_id'])
    return unless message

    mentorship_request = message.mentorship_request
    return unless authorized_for_mentorship_request?(mentorship_request)

    # Users can only mark messages as read if they didn't send them
    return if message.user == current_user

    unless message.read?
      message.mark_as_read!
      broadcast_status_update(message)
    end
  end

  private

  def find_mentorship_request
    MentorshipRequest.find_by(id: params[:mentorship_request_id])
  end

  def authorized_for_mentorship_request?(mentorship_request)
    return false unless current_user

    mentorship_request.mentee == current_user || mentorship_request.mentor == current_user
  end

  def broadcast_typing_update(metadata)
    ActionCable.server.broadcast(
      "mentorship_request_#{metadata.mentorship_request_id}_typing",
      {
        type: 'typing_update',
        user_id: metadata.user_id,
        user_name: metadata.user.profile&.name || metadata.user.email,
        typing: metadata.typing?,
        updated_at: metadata.typing_updated_at
      }
    )
  end

  def broadcast_status_update(message)
    ActionCable.server.broadcast(
      "mentorship_request_#{message.mentorship_request_id}_status",
      {
        type: 'message_status_update',
        message_id: message.id,
        status: message.read? ? 'read' : 'sent',
        read_at: message.read_at
      }
    )
  end
end