require 'rails_helper'

RSpec.describe "MentorshipRequests", type: :request do
  let(:mentee) { create(:user, :mentee) }
  let(:mentor) { create(:user, :mentor) }
  let(:other_user) { create(:user, :mentee) }

  describe "GET /mentorship_requests" do
    context "when not authenticated" do
      it "shows only open requests" do
        open_request = create(:mentorship_request, :open)
        accepted_request = create(:mentorship_request, :accepted)

        get mentorship_requests_path

        expect(response).to have_http_status(:success)
        expect(response.body).to include(open_request.topic)
        expect(response.body).not_to include(accepted_request.topic)
      end
    end

    context "when authenticated" do
      before { sign_in mentee }

      it "shows user's requests as mentee" do
        my_request = create(:mentorship_request, mentee: mentee)
        other_request = create(:mentorship_request, mentee: other_user)

        get mentorship_requests_path

        expect(response.body).to include(my_request.topic)
        expect(response.body).not_to include(other_request.topic)
      end

      it "shows user's requests as mentor" do
        my_request = create(:mentorship_request, :accepted, mentor: mentee)
        other_request = create(:mentorship_request, :accepted, mentor: other_user)

        get mentorship_requests_path

        expect(response.body).to include(my_request.topic)
        expect(response.body).not_to include(other_request.topic)
      end

      it "orders requests by created_at descending" do
        old_request = create(:mentorship_request, mentee: mentee)
        old_request.update_column(:created_at, 2.days.ago)

        new_request = create(:mentorship_request, mentee: mentee)
        new_request.update_column(:created_at, 1.hour.ago)

        get mentorship_requests_path

        # Newer request should appear first
        old_pos = response.body.index(old_request.topic)
        new_pos = response.body.index(new_request.topic)

        expect(new_pos).to be < old_pos if old_pos && new_pos
      end
    end
  end

  describe "GET /mentorship_requests/:id" do
    let(:mentorship_request) { create(:mentorship_request, :accepted, mentee: mentee, mentor: mentor) }

    it "shows the request when authenticated" do
      sign_in mentee

      get mentorship_request_path(mentorship_request)
      expect(response).to have_http_status(:success)
    end

    it "displays request details" do
      sign_in mentee

      get mentorship_request_path(mentorship_request)
      expect(response.body).to include(mentorship_request.topic)
      expect(response.body).to include(mentorship_request.goals)
    end
  end

  describe "GET /mentorship_requests/new" do
    context "when authenticated" do
      before { sign_in mentee }

      it "returns success" do
        get new_mentorship_request_path
        expect(response).to have_http_status(:success)
      end

      it "pre-fills mentor_id from params" do
        get new_mentorship_request_path, params: { mentorship_request: { mentor_id: mentor.id } }
        expect(response.body).to include(mentor.id.to_s)
      end
    end

    context "when not authenticated" do
      it "redirects to sign in" do
        get new_mentorship_request_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "POST /mentorship_requests" do
    context "when authenticated" do
      before { sign_in mentee }

      it "creates a new request with valid params" do
        expect {
          post mentorship_requests_path, params: {
            mentorship_request: {
              topic: "Learning Ruby on Rails",
              goals: "Build my first Rails app",
              preferred_times: "Weekends"
            }
          }
        }.to change(MentorshipRequest, :count).by(1)
      end

      it "sets current user as mentee" do
        post mentorship_requests_path, params: {
          mentorship_request: {
            topic: "Learning Ruby",
            goals: "Master the basics"
          }
        }

        request = MentorshipRequest.last
        expect(request.mentee).to eq(mentee)
      end

      it "does not create request without topic" do
        expect {
          post mentorship_requests_path, params: {
            mentorship_request: {
              goals: "Learn stuff"
            }
          }
        }.not_to change(MentorshipRequest, :count)
      end

      it "can specify a mentor" do
        post mentorship_requests_path, params: {
          mentorship_request: {
            mentor_id: mentor.id,
            topic: "Rails Mentorship",
            goals: "Learn Rails"
          }
        }

        request = MentorshipRequest.last
        expect(request.mentor).to eq(mentor)
      end
    end

    context "when not authenticated" do
      it "redirects to sign in" do
        post mentorship_requests_path, params: {
          mentorship_request: {
            topic: "Test",
            goals: "Test"
          }
        }

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "PATCH /mentorship_requests/:id" do
    context "when authenticated as mentee" do
      it "updates the request" do
        user = create(:user, :mentee)
        mentorship_request = create(:mentorship_request, mentee: user)
        sign_in user

        patch mentorship_request_path(mentorship_request), params: {
          mentorship_request: {
            topic: "Updated Topic"
          }
        }

        expect(mentorship_request.reload.topic).to eq("Updated Topic")
      end

      it "redirects to show page" do
        user = create(:user, :mentee)
        mentorship_request = create(:mentorship_request, mentee: user)
        sign_in user

        patch mentorship_request_path(mentorship_request), params: {
          mentorship_request: {
            topic: "Updated Topic"
          }
        }

        expect(response).to redirect_to(mentorship_request_path(mentorship_request))
      end
    end

    context "when not authenticated" do
      it "redirects to sign in" do
        mentorship_request = create(:mentorship_request, mentee: mentee)

        patch mentorship_request_path(mentorship_request), params: {
          mentorship_request: {
            topic: "Updated"
          }
        }

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "DELETE /mentorship_requests/:id" do
    let!(:mentorship_request) { create(:mentorship_request, mentee: mentee) }

    context "when authenticated as mentee" do
      before { sign_in mentee }

      it "destroys the request" do
        expect {
          delete mentorship_request_path(mentorship_request)
        }.to change(MentorshipRequest, :count).by(-1)
      end

      it "redirects to index" do
        delete mentorship_request_path(mentorship_request)
        expect(response).to redirect_to(mentorship_requests_path)
      end
    end

    context "when not authenticated" do
      it "redirects to sign in" do
        delete mentorship_request_path(mentorship_request)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "POST /mentorship_requests/:id/accept" do
    let(:mentorship_request) { create(:mentorship_request, :open, mentor: mentor) }

    context "when authenticated as assigned mentor" do
      before { sign_in mentor }

      it "accepts the request" do
        post accept_mentorship_request_path(mentorship_request)

        expect(mentorship_request.reload.status).to eq("accepted")
      end

      it "redirects to request with success notice" do
        post accept_mentorship_request_path(mentorship_request)

        expect(response).to redirect_to(mentorship_request_path(mentorship_request))
        follow_redirect!
        expect(response.body).to include("accepted")
      end
    end

    context "when authenticated as different user" do
      before { sign_in other_user }

      it "does not accept the request" do
        post accept_mentorship_request_path(mentorship_request)

        expect(mentorship_request.reload.status).to eq("open")
      end

      it "redirects with error" do
        post accept_mentorship_request_path(mentorship_request)

        expect(response).to redirect_to(mentorship_request_path(mentorship_request))
        follow_redirect!
        expect(response.body).to include("only accept requests assigned to you")
      end
    end

    context "when not authenticated" do
      it "redirects to sign in" do
        post accept_mentorship_request_path(mentorship_request)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "POST /mentorship_requests/:id/decline" do
    let(:mentorship_request) { create(:mentorship_request, :open, mentor: mentor) }

    context "when authenticated as assigned mentor" do
      it "closes the request" do
        sign_in mentor

        post decline_mentorship_request_path(mentorship_request)

        expect(mentorship_request.reload.status).to eq("closed")
      end

      it "removes mentor assignment" do
        sign_in mentor

        post decline_mentorship_request_path(mentorship_request)

        expect(mentorship_request.reload.mentor_id).to be_nil
      end

      it "redirects to index" do
        sign_in mentor

        post decline_mentorship_request_path(mentorship_request)
        expect(response).to redirect_to(mentorship_requests_path)
      end
    end

    context "when authenticated as different user" do
      it "does not decline the request" do
        sign_in other_user

        post decline_mentorship_request_path(mentorship_request)

        expect(mentorship_request.reload.status).to eq("open")
      end
    end
  end

  describe "POST /mentorship_requests/:id/close" do
    let(:mentorship_request) { create(:mentorship_request, :accepted, mentee: mentee, mentor: mentor) }

    context "when authenticated as mentee" do
      it "closes the request" do
        sign_in mentee

        post close_mentorship_request_path(mentorship_request)

        expect(mentorship_request.reload.status).to eq("closed")
      end

      it "redirects to index" do
        sign_in mentee

        post close_mentorship_request_path(mentorship_request)
        expect(response).to redirect_to(mentorship_requests_path)
      end
    end

    context "when authenticated as mentor" do
      it "closes the request" do
        sign_in mentor

        post close_mentorship_request_path(mentorship_request)

        expect(mentorship_request.reload.status).to eq("closed")
      end
    end

    context "when authenticated as different user" do
      it "does not close the request" do
        sign_in other_user

        post close_mentorship_request_path(mentorship_request)

        expect(mentorship_request.reload.status).to eq("accepted")
      end

      it "shows error message" do
        sign_in other_user

        post close_mentorship_request_path(mentorship_request)

        expect(response).to redirect_to(mentorship_request_path(mentorship_request))
        expect(flash[:alert]).to include("permission")
      end
    end

    context "when not authenticated" do
      it "redirects to sign in" do
        post close_mentorship_request_path(mentorship_request)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end

