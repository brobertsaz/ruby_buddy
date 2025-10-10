require 'rails_helper'

RSpec.describe "Api::MessageStatusController", type: :request do
  let(:mentee) { create(:user, :mentee) }
  let(:mentor) { create(:user, :mentor) }
  let(:mentorship_request) { create(:mentorship_request, mentee: mentee, mentor: mentor) }
  let(:message_from_mentee) { create(:message, mentorship_request: mentorship_request, user: mentee) }
  let(:message_from_mentor) { create(:message, mentorship_request: mentorship_request, user: mentor) }

  describe "POST /api/messages/:id/mark_read" do
    context "when not authenticated" do
      it "returns unauthorized" do
        post "/api/messages/#{message_from_mentee.id}/mark_read"

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to eq({
          "success" => false,
          "error" => "Unauthorized access"
        })
      end
    end

    context "when authenticated as mentor" do
      before { sign_in mentor }

      it "marks mentee's message as read" do
        expect(message_from_mentee.read?).to be false

        post "/api/messages/#{message_from_mentee.id}/mark_read"

        expect(response).to have_http_status(:success)
        expect(message_from_mentee.reload.read?).to be true

        response_body = JSON.parse(response.body)
        expect(response_body["success"]).to be true
        expect(response_body["message"]).to eq("Message marked as read")
        expect(response_body["read_at"]).to be_present
      end

      it "returns success if message already read" do
        message_from_mentee.mark_as_read!

        post "/api/messages/#{message_from_mentee.id}/mark_read"

        expect(response).to have_http_status(:success)
        response_body = JSON.parse(response.body)
        expect(response_body["message"]).to eq("Message already read")
      end

      it "forbids marking own message as read" do
        post "/api/messages/#{message_from_mentor.id}/mark_read"

        expect(response).to have_http_status(:forbidden)
        expect(JSON.parse(response.body)).to eq({
          "success" => false,
          "error" => "Access forbidden"
        })
      end
    end

    context "when authenticated as unauthorized user" do
      let(:other_user) { create(:user, :mentor) }
      before { sign_in other_user }

      it "forbids access to message" do
        post "/api/messages/#{message_from_mentee.id}/mark_read"

        expect(response).to have_http_status(:forbidden)
      end
    end

    context "with non-existent message" do
      before { sign_in mentor }

      it "returns not found" do
        post "/api/messages/99999/mark_read"

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)).to eq({
          "success" => false,
          "error" => "Message not found"
        })
      end
    end
  end

  describe "GET /api/messages/:id/status" do
    before { sign_in mentor }

    it "returns message status for unread message" do
      get "/api/messages/#{message_from_mentee.id}/status"

      expect(response).to have_http_status(:success)
      response_body = JSON.parse(response.body)
      expect(response_body["success"]).to be true
      expect(response_body["status"]).to eq("sent")
      expect(response_body["sent_at"]).to be_present
      expect(response_body["read_at"]).to be_nil
    end

    it "returns message status for read message" do
      message_from_mentee.mark_as_read!

      get "/api/messages/#{message_from_mentee.id}/status"

      expect(response).to have_http_status(:success)
      response_body = JSON.parse(response.body)
      expect(response_body["status"]).to eq("read")
      expect(response_body["read_at"]).to be_present
    end
  end

  describe "POST /api/messages/bulk_mark_read" do
    let!(:message1) { create(:message, mentorship_request: mentorship_request, user: mentee) }
    let!(:message2) { create(:message, mentorship_request: mentorship_request, user: mentee) }
    let!(:message3) { create(:message, mentorship_request: mentorship_request, user: mentor) }

    before { sign_in mentor }

    it "marks multiple messages as read" do
      post "/api/messages/bulk_mark_read", params: {
        message_ids: [message1.id, message2.id]
      }

      expect(response).to have_http_status(:success)
      response_body = JSON.parse(response.body)
      expect(response_body["marked_count"]).to eq(2)

      expect(message1.reload.read?).to be true
      expect(message2.reload.read?).to be true
    end

    it "excludes own messages from bulk marking" do
      post "/api/messages/bulk_mark_read", params: {
        message_ids: [message1.id, message3.id]
      }

      expect(response).to have_http_status(:success)
      response_body = JSON.parse(response.body)
      expect(response_body["marked_count"]).to eq(1)

      expect(message1.reload.read?).to be true
      expect(message3.reload.read?).to be false
    end

    it "returns error when no message IDs provided" do
      post "/api/messages/bulk_mark_read", params: { message_ids: [] }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)).to eq({
        "success" => false,
        "error" => "No message IDs provided"
      })
    end
  end
end
