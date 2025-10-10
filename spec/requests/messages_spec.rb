require 'rails_helper'

RSpec.describe "Messages", type: :request do
  let(:mentee) { create(:user, :mentee) }
  let(:mentor) { create(:user, :mentor) }
  let(:mentorship_request) { create(:mentorship_request, :accepted, mentee: mentee, mentor: mentor) }

  describe "GET /messages" do
    context "when authenticated" do
      it "returns success" do
        sign_in mentee

        get messages_path
        expect(response).to have_http_status(:success)
      end

      it "shows conversations where user is mentee" do
        sign_in mentee

        request_as_mentee = create(:mentorship_request, :accepted, mentee: mentee)
        get messages_path
        expect(response.body).to include(request_as_mentee.topic)
      end

      it "shows conversations where user is mentor" do
        sign_in mentee

        request_as_mentor = create(:mentorship_request, :accepted, mentor: mentee)
        get messages_path
        expect(response.body).to include(request_as_mentor.topic)
      end

      it "does not show other users' conversations" do
        sign_in mentee

        other_user = create(:user, :mentee)
        other_request = create(:mentorship_request, :accepted, mentee: other_user)
        get messages_path
        expect(response.body).not_to include(other_request.topic)
      end
    end

    context "when not authenticated" do
      it "redirects to sign in" do
        get messages_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "POST /messages" do
    context "when authenticated as participant" do
      before { sign_in mentee }

      it "creates a new message with valid params" do
        expect {
          post messages_path, params: {
            message: {
              mentorship_request_id: mentorship_request.id,
              body: "Hello, this is a test message!"
            }
          }
        }.to change(Message, :count).by(1)
      end

      it "sets the current user as message sender" do
        post messages_path, params: {
          message: {
            mentorship_request_id: mentorship_request.id,
            body: "Test message"
          }
        }

        message = Message.last
        expect(message.user).to eq(mentee)
      end

      it "sets sent_at timestamp" do
        post messages_path, params: {
          message: {
            mentorship_request_id: mentorship_request.id,
            body: "Test message"
          }
        }

        message = Message.last
        expect(message.sent_at).to be_present
      end

      it "does not create message with empty body" do
        expect {
          post messages_path, params: {
            message: {
              mentorship_request_id: mentorship_request.id,
              body: ""
            }
          }
        }.not_to change(Message, :count)
      end

      it "does not create message without mentorship_request_id" do
        expect {
          post messages_path, params: {
            message: {
              body: "Test message"
            }
          }
        }.not_to change(Message, :count)
      end
    end

    context "when not authenticated" do
      it "redirects to sign in" do
        post messages_path, params: {
          message: {
            mentorship_request_id: mentorship_request.id,
            body: "Test message"
          }
        }

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "DELETE /messages/:id" do
    context "when authenticated as message owner" do
      it "destroys the message" do
        message = create(:message, mentorship_request: mentorship_request, user: mentee)
        sign_in mentee

        expect {
          delete message_path(message)
        }.to change(Message, :count).by(-1)
      end

      it "redirects to messages index" do
        message = create(:message, mentorship_request: mentorship_request, user: mentee)
        sign_in mentee

        delete message_path(message)
        expect(response).to redirect_to(messages_path)
      end
    end

    context "when not authenticated" do
      it "redirects to sign in" do
        message = create(:message, mentorship_request: mentorship_request, user: mentee)

        delete message_path(message)
        expect(response).to redirect_to(new_user_session_path)
      end

      it "does not destroy the message" do
        message = create(:message, mentorship_request: mentorship_request, user: mentee)

        expect {
          delete message_path(message)
        }.not_to change(Message, :count)
      end
    end
  end

  describe "message ordering" do
    before { sign_in mentee }

    it "orders conversations by most recently updated" do
      old_request = create(:mentorship_request, :accepted, mentee: mentee)
      old_request.update_column(:updated_at, 2.days.ago)

      new_request = create(:mentorship_request, :accepted, mentee: mentee)
      new_request.update_column(:updated_at, 1.hour.ago)

      get messages_path

      # The newer request should appear first in the response
      old_pos = response.body.index(old_request.topic)
      new_pos = response.body.index(new_request.topic)

      expect(new_pos).to be < old_pos if old_pos && new_pos
    end
  end

  describe "conversation participants" do
    it "shows conversation information when authenticated" do
      user = create(:user, :mentee)
      other_user = create(:user, :mentor)
      request = create(:mentorship_request, :accepted, mentee: user, mentor: other_user)

      # Create a conversation with messages
      create(:message, mentorship_request: request, user: user, body: "Hello from mentee")
      create(:message, mentorship_request: request, user: other_user, body: "Hello from mentor")

      sign_in user
      get messages_path

      # Should show the conversation topic
      expect(response.body).to include(request.topic)
    end
  end
end

