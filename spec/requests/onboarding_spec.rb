require 'rails_helper'

RSpec.describe "Onboarding", type: :request do
  let(:user) { create(:user, role: nil, onboarding_completed: false) }
  let(:onboarded_user) { create(:user, :mentee, onboarding_completed: true) }

  describe "GET /onboarding" do
    context "when not authenticated" do
      it "redirects to sign in" do
        get onboarding_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when authenticated but not onboarded" do
      before { sign_in user }

      it "returns success" do
        get onboarding_path
        expect(response).to have_http_status(:success)
      end

      it "renders the onboarding index template" do
        get onboarding_path
        expect(response).to render_template(:index)
      end
    end

    context "when already onboarded" do
      before { sign_in onboarded_user }

      it "redirects to root path" do
        get onboarding_path
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "GET /onboarding/choose_role" do
    context "when not authenticated" do
      it "redirects to sign in" do
        get onboarding_choose_role_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when authenticated but not onboarded" do
      before { sign_in user }

      it "returns success" do
        get onboarding_choose_role_path
        expect(response).to have_http_status(:success)
      end

      it "renders the choose_role template" do
        get onboarding_choose_role_path
        expect(response).to render_template(:choose_role)
      end
    end

    context "when already onboarded" do
      before { sign_in onboarded_user }

      it "redirects to root path" do
        get onboarding_choose_role_path
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "POST /onboarding/set_role" do
    context "when not authenticated" do
      it "redirects to sign in" do
        post onboarding_set_role_path, params: { user: { role: 'mentee' } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when authenticated" do
      before { sign_in user }

      context "with valid mentee role" do
        it "updates user role" do
          post onboarding_set_role_path, params: { user: { role: 'mentee' } }
          expect(user.reload.role).to eq('mentee')
        end

        it "redirects to new mentorship request" do
          post onboarding_set_role_path, params: { user: { role: 'mentee' } }
          expect(response).to redirect_to(new_mentorship_request_path)
        end

        it "shows success notice" do
          post onboarding_set_role_path, params: { user: { role: 'mentee' } }
          expect(flash[:notice]).to eq("Great! Let's create your first mentorship request.")
        end
      end

      context "with valid mentor role" do
        it "updates user role" do
          post onboarding_set_role_path, params: { user: { role: 'mentor' } }
          expect(user.reload.role).to eq('mentor')
        end

        it "redirects to new profile" do
          post onboarding_set_role_path, params: { user: { role: 'mentor' } }
          expect(response).to redirect_to(new_profile_path)
        end

        it "shows success notice" do
          post onboarding_set_role_path, params: { user: { role: 'mentor' } }
          expect(flash[:notice]).to eq("Awesome! Let's set up your mentor profile.")
        end
      end

      context "with both role" do
        it "updates user role" do
          post onboarding_set_role_path, params: { user: { role: 'both' } }
          expect(user.reload.role).to eq('both')
        end

        it "redirects to onboarding complete" do
          post onboarding_set_role_path, params: { user: { role: 'both' } }
          expect(response).to redirect_to(onboarding_complete_path)
        end

        it "shows success notice" do
          post onboarding_set_role_path, params: { user: { role: 'both' } }
          expect(flash[:notice]).to eq("Perfect! You can now mentor others and request mentorship.")
        end
      end

      context "with invalid role" do
        it "does not update user role" do
          post onboarding_set_role_path, params: { user: { role: 'invalid' } }
          expect(user.reload.role).to be_nil
        end

        it "redirects back to choose role" do
          post onboarding_set_role_path, params: { user: { role: 'invalid' } }
          expect(response).to redirect_to(onboarding_choose_role_path)
        end

        it "shows error alert" do
          post onboarding_set_role_path, params: { user: { role: 'invalid' } }
          expect(flash[:alert]).to eq("Please select a role to continue.")
        end
      end

      context "with missing role parameter" do
        it "renders the set_role template" do
          post onboarding_set_role_path, params: { user: { role: '' } }
          expect(response).to have_http_status(:success)
          expect(response).to render_template(:set_role)
        end
      end
    end
  end

  describe "GET /onboarding/complete" do
    context "when not authenticated" do
      it "redirects to sign in" do
        get onboarding_complete_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when authenticated with role" do
      let(:user_with_role) { create(:user, :mentee, onboarding_completed: false) }
      before { sign_in user_with_role }

      it "returns success" do
        get onboarding_complete_path
        expect(response).to have_http_status(:success)
      end

      it "marks onboarding as completed" do
        get onboarding_complete_path
        expect(user_with_role.reload.onboarding_completed).to be true
      end

      it "renders the complete template" do
        get onboarding_complete_path
        expect(response).to render_template(:complete)
      end
    end

    context "when authenticated without role" do
      before { sign_in user }

      it "returns success but doesn't mark as completed" do
        get onboarding_complete_path
        expect(response).to have_http_status(:success)
        expect(user.reload.onboarding_completed).to be false
      end
    end
  end
end
