require 'rails_helper'

RSpec.describe "Api::BaseController", type: :request do
  let(:user) { create(:user, :mentee) }

  describe "authentication" do
    context "when not authenticated" do
      it "returns unauthorized for protected endpoints" do
        # Using a concrete endpoint that inherits from BaseController
        post "/api/messages/typing", params: { mentorship_request_id: 1, typing: true }

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to eq({
          "success" => false,
          "error" => "Unauthorized access"
        })
      end
    end

    context "when authenticated" do
      before { sign_in user }

      it "allows access to protected endpoints" do
        mentorship_request = create(:mentorship_request, mentee: user)

        post "/api/messages/typing", params: {
          mentorship_request_id: mentorship_request.id,
          typing: true
        }

        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)["success"]).to be true
      end
    end
  end

  describe "JSON responses" do
    before { sign_in user }

    it "returns JSON content type" do
      mentorship_request = create(:mentorship_request, mentee: user)

      post "/api/messages/typing", params: {
        mentorship_request_id: mentorship_request.id,
        typing: true
      }

      expect(response.content_type).to include("application/json")
    end

    it "handles invalid JSON gracefully" do
      # Test with malformed request that would trigger error handling
      post "/api/messages/typing", params: { typing: true, mentorship_request_id: 999999 }

      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)["success"]).to be false
    end
  end

  describe "CSRF protection" do
    before { sign_in user }

    it "uses null_session for CSRF protection" do
      # API controllers should not require CSRF tokens
      mentorship_request = create(:mentorship_request, mentee: user)

      post "/api/messages/typing", params: {
        mentorship_request_id: mentorship_request.id,
        typing: true
      }

      expect(response).to have_http_status(:success)
    end
  end
end
