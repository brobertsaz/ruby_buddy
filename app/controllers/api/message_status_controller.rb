class Api::MessageStatusController < Api::BaseController
  before_action :set_message, only: [:mark_read, :status]
  before_action :authorize_message_access, only: [:mark_read, :status]

  # POST /api/messages/:id/mark_read
  def mark_read
    # Users can only mark messages as read if they didn't send them
    if @message.user == current_user
      return render_forbidden
    end

    if @message.read?
      render_json_success("Message already read", {
        read_at: @message.read_at
      })
    else
      @message.mark_as_read!
      render_json_success("Message marked as read", {
        read_at: @message.read_at
      })

      # Broadcast status update via ActionCable
      broadcast_message_status_update
    end
  end

  # GET /api/messages/:id/status
  def status
    render_json_success("Message status", {
      status: @message.read? ? "read" : "sent",
      sent_at: @message.sent_at,
      read_at: @message.read_at
    })
  end

  # POST /api/messages/bulk_mark_read
  def bulk_mark_read
    message_ids = params[:message_ids]

    # Check for nil, empty array, or array with only blank values (Rails converts [] to [""])
    if message_ids.nil? ||
       message_ids == [] ||
       (message_ids.is_a?(Array) && message_ids.empty?) ||
       (message_ids.is_a?(Array) && message_ids.all?(&:blank?))
      return render_json_error("No message IDs provided")
    end

    messages = Message.where(id: message_ids)

    # Ensure user has access to all messages
    accessible_messages = messages.joins(:mentorship_request)
      .where(
        mentorship_requests: {
          mentee_id: current_user.id
        }
      ).or(
        messages.joins(:mentorship_request)
          .where(
            mentorship_requests: {
              mentor_id: current_user.id
            }
          )
      )
      .where.not(user: current_user) # Can't mark own messages as read

    marked_count = 0
    accessible_messages.unread.each do |message|
      message.mark_as_read!
      marked_count += 1
    end

    render_json_success("Messages marked as read", {
      marked_count: marked_count
    })

    # Broadcast updates for all marked messages
    accessible_messages.each { |msg| broadcast_message_status_update(msg) }
  end

  private

  def set_message
    @message = Message.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_json_error("Message not found", :not_found)
  end

  def authorize_message_access
    mentorship_request = @message.mentorship_request

    unless mentorship_request.mentee == current_user || mentorship_request.mentor == current_user
      render_forbidden
    end
  end

  def broadcast_message_status_update(message = @message)
    stream = "mentorship_request_#{message.mentorship_request_id}_status"
    ActionCable.server.broadcast(stream, {
      type: 'message_status_update',
      message_id: message.id,
      status: message.read? ? 'read' : 'sent',
      read_at: message.read_at
    })
  end
end