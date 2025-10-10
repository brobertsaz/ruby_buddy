require 'rails_helper'

RSpec.describe "Api::TypingIndicatorController", type: :request do
  let(:mentee) { create(:user, :mentee) }
  let(:mentor) { create(:user, :mentor) }
  let(:mentorship_request) { create(:mentorship_request, mentee: mentee, mentor: mentor) }

  describe "POST /api/mentorship_requests/:id/typing" do
    context "when not authenticated" do
      it "returns unauthorized" do
        post "/api/mentorship_requests/#{mentorship_request.id}/typing", params: { typing: true }
        
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when authenticated as mentee" do
      before { sign_in mentee }

      it "sets typing status to true" do
        post "/api/mentorship_requests/#{mentorship_request.id}/typing", params: { typing: true }
        
        expect(response).to have_http_status(:success)
        response_body = JSON.parse(response.body)
        expect(response_body["success"]).to be true
        expect(response_body["typing"]).to be true
        
        metadata = ConversationMetadata.find_by(user: mentee, mentorship_request: mentorship_request)
        expect(metadata.typing?).to be true
      end

      it "sets typing status to false" do
        # First set to true
        ConversationMetadata.create!(user: mentee, mentorship_request: mentorship_request, typing: true)
        
        post "/api/mentorship_requests/#{mentorship_request.id}/typing", params: { typing: false }
        
        expect(response).to have_http_status(:success)
        response_body = JSON.parse(response.body)
        expect(response_body["typing"]).to be false
        
        metadata = ConversationMetadata.find_by(user: mentee, mentorship_request: mentorship_request)
        expect(metadata.typing?).to be false
      end

      it "handles string 'true' parameter" do
        post "/api/mentorship_requests/#{mentorship_request.id}/typing", params: { typing: "true" }
        
        expect(response).to have_http_status(:success)
        response_body = JSON.parse(response.body)
        expect(response_body["typing"]).to be true
      end

      it "creates metadata if it doesn't exist" do
        expect(ConversationMetadata.count).to eq(0)
        
        post "/api/mentorship_requests/#{mentorship_request.id}/typing", params: { typing: true }
        
        expect(response).to have_http_status(:success)
        expect(ConversationMetadata.count).to eq(1)
      end
    end

    context "when authenticated as unauthorized user" do
      let(:other_user) { create(:user, :mentor) }
      before { sign_in other_user }

      it "forbids access" do
        post "/api/mentorship_requests/#{mentorship_request.id}/typing", params: { typing: true }
        
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "with non-existent mentorship request" do
      before { sign_in mentee }

      it "returns not found" do
        post "/api/mentorship_requests/99999/typing", params: { typing: true }
        
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)).to eq({
          "success" => false,
          "error" => "Mentorship request not found"
        })
      end
    end
  end

  describe "GET /api/mentorship_requests/:id/typing" do
    before { sign_in mentee }

    it "returns empty list when no one is typing" do
      get "/api/mentorship_requests/#{mentorship_request.id}/typing"
      
      expect(response).to have_http_status(:success)
      response_body = JSON.parse(response.body)
      expect(response_body["typing_users"]).to eq([])
    end

    it "returns typing users excluding current user" do
      # Mentor is typing
      ConversationMetadata.create!(user: mentor, mentorship_request: mentorship_request, typing: true)
      # Mentee is also typing (current user - should be excluded)
      ConversationMetadata.create!(user: mentee, mentorship_request: mentorship_request, typing: true)
      
      get "/api/mentorship_requests/#{mentorship_request.id}/typing"
      
      expect(response).to have_http_status(:success)
      response_body = JSON.parse(response.body)
      expect(response_body["typing_users"].length).to eq(1)
      expect(response_body["typing_users"][0]["id"]).to eq(mentor.id)
      expect(response_body["typing_users"][0]["email"]).to eq(mentor.email)
    end
  end

  describe "POST /api/messages/typing" do
    before { sign_in mentee }

    it "updates typing status for message endpoint" do
      post "/api/messages/typing", params: { 
        mentorship_request_id: mentorship_request.id, 
        typing: true 
      }
      
      expect(response).to have_http_status(:success)
      response_body = JSON.parse(response.body)
      expect(response_body["typing"]).to be true
      
      metadata = ConversationMetadata.find_by(user: mentee, mentorship_request: mentorship_request)
      expect(metadata.typing?).to be true
    end

    it "returns error for non-existent mentorship request" do
      post "/api/messages/typing", params: { 
        mentorship_request_id: 99999, 
        typing: true 
      }
      
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)).to eq({
        "success" => false,
        "error" => "Mentorship request not found"
      })
    end

    it "forbids access to unauthorized mentorship request" do
      other_request = create(:mentorship_request)
      
      post "/api/messages/typing", params: { 
        mentorship_request_id: other_request.id, 
        typing: true 
      }
      
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "POST /api/typing/cleanup" do
    before { sign_in mentee }

    it "cleans up expired typing indicators" do
      # Create expired typing indicator
      old_metadata = ConversationMetadata.create!(
        user: mentor, 
        mentorship_request: mentorship_request, 
        typing: true,
        typing_updated_at: 10.seconds.ago
      )
      
      # Create recent typing indicator
      recent_metadata = ConversationMetadata.create!(
        user: mentee, 
        mentorship_request: mentorship_request, 
        typing: true,
        typing_updated_at: 1.second.ago
      )
      
      post "/api/typing/cleanup"
      
      expect(response).to have_http_status(:success)
      response_body = JSON.parse(response.body)
      expect(response_body["message"]).to eq("Expired typing indicators cleaned up")
      
      # Check that expired indicator was cleaned up
      expect(old_metadata.reload.typing?).to be false
      expect(recent_metadata.reload.typing?).to be true
    end
  end
end
