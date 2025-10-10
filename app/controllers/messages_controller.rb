class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_message, only: %i[ show edit update destroy ]

  # GET /messages or /messages.json
  def index
    # Get all mentorship requests where the user is involved
    @conversations = MentorshipRequest
                       .where("mentee_id = ? OR mentor_id = ?", current_user.id, current_user.id)
                       .includes(:messages, :mentee, :mentor)
                       .order("mentorship_requests.updated_at DESC")
  end

  # GET /messages/1 or /messages/1.json
  def show
  end

  # GET /messages/new
  def new
    @message = Message.new
  end

  # GET /messages/1/edit
  def edit
  end

  # POST /messages or /messages.json
  def create
    @message = Message.new(message_params)
    @message.user = current_user

    respond_to do |format|
      if @message.save
        # Set sent_at after save to ensure it's after created_at
        @message.update_column(:sent_at, Time.current)

        # Broadcast to ALL users viewing this conversation
        # The broadcast will handle showing the message to everyone
        broadcast_message

        # Clear the form for the sender
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace(
            "new_message",
            partial: "messages/form",
            locals: { message: Message.new(mentorship_request: @message.mentorship_request) }
          )
        }
        format.html { redirect_to @message.mentorship_request, notice: "Message posted." }
        format.json { render :show, status: :created, location: @message }
      else
        format.turbo_stream { render turbo_stream: turbo_stream.replace("new_message", partial: "messages/form", locals: { message: @message }) }
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /messages/1 or /messages/1.json
  def update
    respond_to do |format|
      if @message.update(message_params)
        format.html { redirect_to @message, notice: "Message was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @message }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /messages/1 or /messages/1.json
  def destroy
    @message.destroy!

    respond_to do |format|
      format.html { redirect_to messages_path, notice: "Message was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_message
      @message = Message.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def message_params
      params.expect(message: [ :mentorship_request_id, :body ])
    end

    # Broadcast message to all users viewing this conversation
    def broadcast_message
      Turbo::StreamsChannel.broadcast_append_to(
        "mentorship_request_#{@message.mentorship_request_id}_messages",
        target: "mentorship_request_#{@message.mentorship_request_id}_messages",
        partial: "messages/message_broadcast",
        locals: { message: @message }
      )
    end
end
