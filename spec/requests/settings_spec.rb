require 'rails_helper'

RSpec.describe "Settings", type: :request do
  let(:user) { create(:user, :mentee, email: "test@example.com", password: "password123") }

  describe "GET /settings" do
    context "when not authenticated" do
      it "redirects to sign in" do
        get settings_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when authenticated" do
      it "returns success" do
        sign_in user

        get settings_path
        expect(response).to have_http_status(:success)
      end

      it "displays settings page" do
        sign_in user

        get settings_path
        expect(response.body).to include("Settings")
      end
    end
  end

  describe "PATCH /settings/update_role" do
    context "when not authenticated" do
      it "redirects to sign in" do
        patch settings_update_role_path, params: { user: { role: "mentor" } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when authenticated" do
      it "updates role to mentor" do
        sign_in user

        patch settings_update_role_path, params: { user: { role: "mentor" } }

        expect(user.reload.role).to eq("mentor")
      end

      it "updates role to mentee" do
        mentor = create(:user, :mentor)
        sign_in mentor

        patch settings_update_role_path, params: { user: { role: "mentee" } }

        expect(mentor.reload.role).to eq("mentee")
      end

      it "updates role to both" do
        sign_in user

        patch settings_update_role_path, params: { user: { role: "both" } }

        expect(user.reload.role).to eq("both")
      end

      it "redirects to settings with success notice" do
        sign_in user

        patch settings_update_role_path, params: { user: { role: "mentor" } }

        expect(response).to redirect_to(settings_path)
        expect(flash[:notice]).to eq("Role updated successfully!")
      end

      it "handles invalid role" do
        sign_in user

        patch settings_update_role_path, params: { user: { role: "invalid" } }

        expect(response).to redirect_to(settings_path)
        expect(flash[:alert]).to eq("Failed to update role.")
      end
    end
  end

  describe "PATCH /settings/update_email" do
    context "when not authenticated" do
      it "redirects to sign in" do
        patch settings_update_email_path, params: { user: { email: "new@example.com" } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when authenticated" do
      it "updates email with valid email" do
        sign_in user

        patch settings_update_email_path, params: { user: { email: "newemail@example.com" } }

        expect(user.reload.email).to eq("newemail@example.com")
      end

      it "redirects to settings with success notice" do
        sign_in user

        patch settings_update_email_path, params: { user: { email: "newemail@example.com" } }

        expect(response).to redirect_to(settings_path)
        expect(flash[:notice]).to eq("Email updated successfully!")
      end

      it "does not update with invalid email" do
        sign_in user

        patch settings_update_email_path, params: { user: { email: "invalid" } }

        expect(user.reload.email).to eq("test@example.com")
      end

      it "shows error for invalid email" do
        sign_in user

        patch settings_update_email_path, params: { user: { email: "invalid" } }

        expect(response).to redirect_to(settings_path)
        expect(flash[:alert]).to include("Failed to update email")
      end

      it "does not update with duplicate email" do
        other_user = create(:user, email: "taken@example.com")
        sign_in user

        patch settings_update_email_path, params: { user: { email: "taken@example.com" } }

        expect(user.reload.email).to eq("test@example.com")
        expect(flash[:alert]).to include("Failed to update email")
      end
    end
  end

  describe "PATCH /settings/update_password" do
    context "when not authenticated" do
      it "redirects to sign in" do
        patch settings_update_password_path, params: {
          user: {
            current_password: "password123",
            password: "newpassword123",
            password_confirmation: "newpassword123"
          }
        }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when authenticated" do
      it "updates password with valid current password" do
        sign_in user

        patch settings_update_password_path, params: {
          user: {
            current_password: "password123",
            password: "newpassword123",
            password_confirmation: "newpassword123"
          }
        }

        expect(response).to redirect_to(settings_path)
        expect(flash[:notice]).to eq("Password updated successfully!")
      end

      it "allows sign in with new password" do
        sign_in user

        patch settings_update_password_path, params: {
          user: {
            current_password: "password123",
            password: "newpassword456",
            password_confirmation: "newpassword456"
          }
        }

        # User should still be signed in after password change
        expect(user.reload.valid_password?("newpassword456")).to be true
      end

      it "does not update with wrong current password" do
        sign_in user

        patch settings_update_password_path, params: {
          user: {
            current_password: "wrongpassword",
            password: "newpassword123",
            password_confirmation: "newpassword123"
          }
        }

        expect(flash[:alert]).to include("Failed to update password")
        expect(user.reload.valid_password?("password123")).to be true
      end

      it "does not update with mismatched confirmation" do
        sign_in user

        patch settings_update_password_path, params: {
          user: {
            current_password: "password123",
            password: "newpassword123",
            password_confirmation: "different123"
          }
        }

        expect(flash[:alert]).to include("Failed to update password")
      end

      it "does not update with blank password" do
        sign_in user

        patch settings_update_password_path, params: {
          user: {
            current_password: "password123",
            password: "",
            password_confirmation: ""
          }
        }

        expect(flash[:alert]).to eq("Password cannot be blank.")
      end

      it "does not update with too short password" do
        sign_in user

        patch settings_update_password_path, params: {
          user: {
            current_password: "password123",
            password: "short",
            password_confirmation: "short"
          }
        }

        expect(flash[:alert]).to include("Failed to update password")
      end
    end
  end
end

