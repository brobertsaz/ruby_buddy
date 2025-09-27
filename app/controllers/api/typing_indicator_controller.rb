class Api::TypingIndicatorController < Api::BaseController
  before_action :set_mentorship_request, only: [:update_for_request, :get_typing_users]
  before_action :authorize_mentorship_access, only: [:update_for_request, :get_typing_users]

  # POST /api/mentorship_requests/:id/typing
  def update_for_request
    typing_status = params[:typing] == true || params[:typing] == "true"

    metadata = ConversationMetadata.find_or_initialize_for_user_and_request(
      current_user,
      @mentorship_request
    )

    metadata.typing = typing_status
    metadata.typing_updated_at = Time.current

    if metadata.save
      render_json_success("Typing status updated", {
        typing: metadata.typing?
      })

      # Broadcast typing indicator update
      broadcast_typing_update(metadata)
    else
      render_json_error("Failed to update typing status")
    end
  end

  # GET /api/mentorship_requests/:id/typing
  def get_typing_users
    typing_users = @mentorship_request.users_typing_except(current_user)

    render_json_success("Typing users retrieved", {
      typing_users: typing_users.map do |user|
        {
          id: user.id,
          email: user.email,
          name: user.profile&.name || user.email
        }
      end
    })
  end

  # POST /api/messages/typing
  def update_for_message
    mentorship_request_id = params[:mentorship_request_id]
    typing_status = params[:typing] == true || params[:typing] == "true"

    mentorship_request = MentorshipRequest.find(mentorship_request_id)

    unless mentorship_request.mentee == current_user || mentorship_request.mentor == current_user
      return render_forbidden
    end

    metadata = ConversationMetadata.find_or_initialize_for_user_and_request(
      current_user,
      mentorship_request
    )

    metadata.typing = typing_status
    metadata.typing_updated_at = Time.current

    if metadata.save
      render_json_success("Typing status updated", {
        typing: metadata.typing?
      })

      # Broadcast typing indicator update
      broadcast_typing_update(metadata)
    else
      render_json_error("Failed to update typing status")
    end
  rescue ActiveRecord::RecordNotFound
    render_json_error("Mentorship request not found", :not_found)
  end

  # POST /api/typing/cleanup
  def cleanup_expired
    ConversationMetadata.cleanup_expired_typing_indicators

    render_json_success("Expired typing indicators cleaned up")
  end

  private

  def set_mentorship_request
    @mentorship_request = MentorshipRequest.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_json_error("Mentorship request not found", :not_found)
  end

  def authorize_mentorship_access
    unless @mentorship_request.mentee == current_user || @mentorship_request.mentor == current_user
      render_forbidden
    end
  end

  def broadcast_typing_update(metadata)
    stream = "mentorship_request_#{metadata.mentorship_request_id}_typing"

    ActionCable.server.broadcast(stream, {
      type: 'typing_update',
      user_id: metadata.user_id,
      user_name: metadata.user.profile&.name || metadata.user.email,
      typing: metadata.typing?,
      updated_at: metadata.typing_updated_at
    })
  end
end