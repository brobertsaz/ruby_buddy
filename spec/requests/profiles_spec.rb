require 'rails_helper'

RSpec.describe "Profiles", type: :request do
  let(:user) { create(:user, :mentee) }
  let(:mentor_user) { create(:user, :mentor) }
  let(:other_user) { create(:user, :mentee) }

  describe "GET /profiles" do
    it "shows mentor profiles to anyone" do
      mentor_profile = create(:profile, :mentor, name: "Jane Mentor")
      mentee_profile = create(:profile, :mentee, name: "John Mentee")

      get profiles_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Jane Mentor")
      expect(response.body).not_to include("John Mentee")
    end

    it "filters profiles by search query" do
      ruby_mentor = create(:profile, :mentor, name: "RubyExpertUnique", skills: "Ruby, Rails")
      python_mentor = create(:profile, :mentor, name: "PythonExpertUnique", skills: "Python, Django")

      get profiles_path, params: { q: "RubyExpertUnique" }

      expect(response.body).to include("RubyExpertUnique")
      expect(response.body).not_to include("PythonExpertUnique")
    end

    it "searches in name, skills, and bio" do
      profile = create(:profile, :mentor, name: "Test", bio: "Loves JavaScript", skills: "React")

      get profiles_path, params: { q: "JavaScript" }
      expect(response.body).to include("Test")

      get profiles_path, params: { q: "React" }
      expect(response.body).to include("Test")
    end

    it "is case insensitive" do
      profile = create(:profile, :mentor, name: "Ruby Developer")

      get profiles_path, params: { q: "ruby" }
      expect(response.body).to include("Ruby Developer")
    end

    it "orders by created_at descending" do
      old_profile = create(:profile, :mentor, name: "Old Mentor")
      old_profile.update_column(:created_at, 2.days.ago)

      new_profile = create(:profile, :mentor, name: "New Mentor")
      new_profile.update_column(:created_at, 1.hour.ago)

      get profiles_path

      # Newer profile should appear first
      old_pos = response.body.index("Old Mentor")
      new_pos = response.body.index("New Mentor")

      expect(new_pos).to be < old_pos if old_pos && new_pos
    end
  end

  describe "GET /profiles/:id" do
    it "shows profile to anyone" do
      profile = create(:profile, :mentor, user: mentor_user)

      get profile_path(profile)

      expect(response).to have_http_status(:success)
      expect(response.body).to include(profile.name)
    end

    it "displays profile details" do
      profile = create(:profile, :mentor,
        name: "Test Mentor",
        bio: "I love teaching Ruby",
        skills: "Ruby, Rails, TDD"
      )

      get profile_path(profile)

      expect(response.body).to include("Test Mentor")
      expect(response.body).to include("I love teaching Ruby")
      # Skills are displayed as individual tags, not comma-separated
      expect(response.body).to include("Ruby")
      expect(response.body).to include("Rails")
      expect(response.body).to include("TDD")
    end
  end

  describe "GET /profiles/new" do
    context "when authenticated" do
      it "returns success" do
        new_user = create(:user, :mentee)
        sign_in new_user

        get new_profile_path
        expect(response).to have_http_status(:success)
      end

      it "builds profile for current user" do
        new_user = create(:user, :mentee)
        sign_in new_user

        get new_profile_path
        expect(response.body).to include("Create Your Profile")
      end
    end

    context "when not authenticated" do
      it "redirects to sign in" do
        get new_profile_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "POST /profiles" do
    context "when not authenticated" do
      it "redirects to sign in" do
        post profiles_path, params: {
          profile: {
            name: "Test",
            bio: "Bio"
          }
        }

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "GET /profiles/:id/edit" do
    context "when authenticated as profile owner" do
      it "returns success" do
        profile = create(:profile, user: user)
        sign_in user

        get edit_profile_path(profile)
        expect(response).to have_http_status(:success)
      end
    end

    context "when not authenticated" do
      it "redirects to sign in" do
        profile = create(:profile, user: user)

        get edit_profile_path(profile)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "PATCH /profiles/:id" do
    context "when authenticated as profile owner" do
      it "updates the profile" do
        profile = create(:profile, user: user, name: "Old Name")
        sign_in user

        patch profile_path(profile), params: {
          profile: {
            name: "New Name"
          }
        }

        expect(profile.reload.name).to eq("New Name")
      end

      it "redirects to profile show page" do
        profile = create(:profile, user: user)
        sign_in user

        patch profile_path(profile), params: {
          profile: {
            name: "Updated"
          }
        }

        expect(response).to redirect_to(profile_path(profile))
      end

      it "can update mentor/mentee flags" do
        profile = create(:profile, user: user, mentor: false, mentee: true)
        sign_in user

        patch profile_path(profile), params: {
          profile: {
            mentor: true,
            mentee: true
          }
        }

        profile.reload
        expect(profile.mentor).to be true
        expect(profile.mentee).to be true
      end
    end

    context "when not authenticated" do
      it "redirects to sign in" do
        profile = create(:profile, user: user)

        patch profile_path(profile), params: {
          profile: {
            name: "Updated"
          }
        }

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "DELETE /profiles/:id" do
    context "when authenticated as profile owner" do
      it "destroys the profile" do
        profile = create(:profile, user: user)
        sign_in user

        expect {
          delete profile_path(profile)
        }.to change(Profile, :count).by(-1)
      end

      it "redirects to profiles index" do
        profile = create(:profile, user: user)
        sign_in user

        delete profile_path(profile)
        expect(response).to redirect_to(profiles_path)
      end
    end

    context "when not authenticated" do
      it "redirects to sign in" do
        profile = create(:profile, user: user)

        delete profile_path(profile)
        expect(response).to redirect_to(new_user_session_path)
      end

      it "does not destroy the profile" do
        profile = create(:profile, user: user)

        expect {
          delete profile_path(profile)
        }.not_to change(Profile, :count)
      end
    end
  end
end

