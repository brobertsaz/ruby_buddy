require 'rails_helper'

RSpec.describe "Authentication", type: :request do
  describe "POST /users (sign up)" do
    it "creates a new user with valid credentials" do
      expect {
        post user_registration_path, params: {
          user: {
            email: "newuser@example.com",
            password: "password123",
            password_confirmation: "password123"
          }
        }
      }.to change(User, :count).by(1)

      # New users are redirected to onboarding
      expect(response).to redirect_to(onboarding_path)
    end

    it "does not create user with invalid email" do
      expect {
        post user_registration_path, params: {
          user: {
            email: "invalid_email",
            password: "password123",
            password_confirmation: "password123"
          }
        }
      }.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "does not create user with short password" do
      expect {
        post user_registration_path, params: {
          user: {
            email: "newuser@example.com",
            password: "short",
            password_confirmation: "short"
          }
        }
      }.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "does not create user with mismatched password confirmation" do
      expect {
        post user_registration_path, params: {
          user: {
            email: "newuser@example.com",
            password: "password123",
            password_confirmation: "different"
          }
        }
      }.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "does not create user with duplicate email" do
      create(:user, email: "existing@example.com")

      expect {
        post user_registration_path, params: {
          user: {
            email: "existing@example.com",
            password: "password123",
            password_confirmation: "password123"
          }
        }
      }.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "POST /users/sign_in (sign in)" do
    let!(:user) { create(:user, email: "test@example.com", password: "password123") }

    it "signs in with valid credentials" do
      post user_session_path, params: {
        user: {
          email: user.email,
          password: "password123"
        }
      }

      expect(response).to have_http_status(:redirect)
    end

    it "does not sign in with invalid email" do
      post user_session_path, params: {
        user: {
          email: "wrong@example.com",
          password: "password123"
        }
      }

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "does not sign in with invalid password" do
      post user_session_path, params: {
        user: {
          email: "test@example.com",
          password: "wrongpassword"
        }
      }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "DELETE /users/sign_out (sign out)" do
    it "signs out authenticated user" do
      user = create(:user, :mentee)
      sign_in user

      delete destroy_user_session_path

      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(response.body).to include("Signed out successfully")
    end

    it "redirects unauthenticated user" do
      delete destroy_user_session_path

      # Unauthenticated users are redirected to root
      expect(response).to redirect_to(root_path)
    end
  end

  describe "authentication requirements" do
    it "allows access to public pages without authentication" do
      get root_path
      expect(response).to have_http_status(:success)
    end

    it "redirects to sign in for protected pages" do
      get dashboard_path

      expect(response).to redirect_to(new_user_session_path)
    end

    it "allows access to protected pages when authenticated" do
      user = create(:user, :mentee)
      sign_in user

      get dashboard_path

      # Authenticated users can access dashboard
      expect(response).to have_http_status(:success)
    end
  end
end

