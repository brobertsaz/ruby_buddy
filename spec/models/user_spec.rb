require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_one(:profile).dependent(:destroy) }
    it { should have_many(:mentorship_requests_as_mentee).class_name('MentorshipRequest').with_foreign_key(:mentee_id) }
    it { should have_many(:mentorship_requests_as_mentor).class_name('MentorshipRequest').with_foreign_key(:mentor_id) }
    it { should have_many(:messages).dependent(:destroy) }
  end

  describe 'validations' do
    subject { build(:user) }

    # Devise validations
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should allow_value('user@example.com').for(:email) }
    it { should_not allow_value('invalid_email').for(:email) }

    # Password validations
    it { should validate_length_of(:password).is_at_least(6) }

    # Role validation
    it { should allow_value('mentee').for(:role) }
    it { should allow_value('mentor').for(:role) }
    it { should allow_value('both').for(:role) }
    it { should allow_value(nil).for(:role) }
    it { should_not allow_value('invalid_role').for(:role) }
  end

  describe 'role methods' do
    describe '#mentee?' do
      it 'returns true when role is mentee' do
        user = build(:user, role: 'mentee')
        expect(user.mentee?).to be true
      end

      it 'returns true when role is both' do
        user = build(:user, role: 'both')
        expect(user.mentee?).to be true
      end

      it 'returns false when role is mentor' do
        user = build(:user, role: 'mentor')
        expect(user.mentee?).to be false
      end

      it 'returns false when role is nil' do
        user = build(:user, role: nil)
        expect(user.mentee?).to be false
      end
    end

    describe '#mentor?' do
      it 'returns true when role is mentor' do
        user = build(:user, role: 'mentor')
        expect(user.mentor?).to be true
      end

      it 'returns true when role is both' do
        user = build(:user, role: 'both')
        expect(user.mentor?).to be true
      end

      it 'returns false when role is mentee' do
        user = build(:user, role: 'mentee')
        expect(user.mentor?).to be false
      end

      it 'returns false when role is nil' do
        user = build(:user, role: nil)
        expect(user.mentor?).to be false
      end
    end
  end

  describe '#needs_onboarding?' do
    it 'returns true when role is blank' do
      user = build(:user, role: nil, onboarding_completed: false)
      expect(user.needs_onboarding?).to be true
    end

    it 'returns true when onboarding is not completed' do
      user = build(:user, role: 'mentee', onboarding_completed: false)
      expect(user.needs_onboarding?).to be true
    end

    it 'returns false when role is set and onboarding is completed' do
      user = build(:user, role: 'mentee', onboarding_completed: true)
      expect(user.needs_onboarding?).to be false
    end
  end

  describe '#display_role' do
    it 'returns "Looking for a Mentor" for mentee role' do
      user = build(:user, role: 'mentee')
      expect(user.display_role).to eq('Looking for a Mentor')
    end

    it 'returns "Available Mentor" for mentor role' do
      user = build(:user, role: 'mentor')
      expect(user.display_role).to eq('Available Mentor')
    end

    it 'returns "Mentor & Mentee" for both role' do
      user = build(:user, role: 'both')
      expect(user.display_role).to eq('Mentor & Mentee')
    end

    it 'returns "Not Set" when role is nil' do
      user = build(:user, role: nil)
      expect(user.display_role).to eq('Not Set')
    end
  end

  describe '#display_name' do
    it 'returns profile name when profile exists' do
      user = create(:user, :with_profile)
      expect(user.display_name).to eq(user.profile.name)
    end

    it 'returns email username when profile does not exist' do
      user = create(:user, email: 'testuser@example.com')
      expect(user.display_name).to eq('testuser')
    end

    it 'returns "User" when email is nil' do
      user = build(:user, email: nil)
      allow(user).to receive(:email).and_return(nil)
      expect(user.display_name).to eq('User')
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:user)).to be_valid
    end

    it 'creates a mentee with profile' do
      user = create(:user, :mentee)
      expect(user.role).to eq('mentee')
      expect(user.profile).to be_present
      expect(user.profile.mentee).to be true
    end

    it 'creates a mentor with profile' do
      user = create(:user, :mentor)
      expect(user.role).to eq('mentor')
      expect(user.profile).to be_present
      expect(user.profile.mentor).to be true
    end

    it 'creates a user with both roles' do
      user = create(:user, :both)
      expect(user.role).to eq('both')
      expect(user.profile).to be_present
      expect(user.profile.mentor).to be true
      expect(user.profile.mentee).to be true
    end
  end

  describe 'Devise functionality' do
    it 'encrypts password' do
      user = create(:user, password: 'password123')
      expect(user.encrypted_password).to be_present
      expect(user.encrypted_password).not_to eq('password123')
    end

    it 'authenticates with valid password' do
      user = create(:user, password: 'password123')
      expect(user.valid_password?('password123')).to be true
    end

    it 'does not authenticate with invalid password' do
      user = create(:user, password: 'password123')
      expect(user.valid_password?('wrong_password')).to be false
    end

    it 'requires password confirmation to match' do
      user = build(:user, password: 'password123', password_confirmation: 'different')
      expect(user).not_to be_valid
      expect(user.errors[:password_confirmation]).to include("doesn't match Password")
    end
  end

  describe 'dependent destroy' do
    it 'destroys associated profile when user is destroyed' do
      user = create(:user, :with_profile)
      profile_id = user.profile.id

      user.destroy

      expect(Profile.find_by(id: profile_id)).to be_nil
    end

    it 'destroys associated messages when user is destroyed' do
      mentor = create(:user, :mentor)
      mentee = create(:user, :mentee)
      request = create(:mentorship_request, mentee: mentee, mentor: mentor)
      message = create(:message, user: mentee, mentorship_request: request)
      message_id = message.id

      mentee.destroy

      expect(Message.find_by(id: message_id)).to be_nil
    end

    it 'destroys mentorship requests as mentee when user is destroyed' do
      user = create(:user, :mentee)
      request = create(:mentorship_request, mentee: user)
      request_id = request.id

      user.destroy

      expect(MentorshipRequest.find_by(id: request_id)).to be_nil
    end

    it 'nullifies mentorship requests as mentor when user is destroyed' do
      mentor = create(:user, :mentor)
      mentee = create(:user, :mentee)
      request = create(:mentorship_request, :accepted, mentee: mentee, mentor: mentor)
      request_id = request.id

      mentor.destroy

      request = MentorshipRequest.find_by(id: request_id)
      expect(request).to be_present
      expect(request.mentor_id).to be_nil
    end
  end

  describe 'edge cases' do
    describe '#display_name' do
      it 'handles user with no profile and empty email' do
        user = create(:user, email: 'test@example.com')
        user.update_column(:email, '') # Bypass validations to test edge case
        expect(user.display_name).to eq('User')
      end

      it 'handles user with profile but no name' do
        user = create(:user, :mentee)
        user.profile.update(name: nil)
        expect(user.display_name).to eq(user.email.split('@').first)
      end

      it 'handles email with no @ symbol' do
        user = build(:user, email: 'invalid-email')
        user.save(validate: false) # Skip validations
        expect(user.display_name).to eq('invalid-email')
      end
    end

    describe '#needs_onboarding?' do
      it 'returns true when role is nil and onboarding_completed is false' do
        user = create(:user, role: nil, onboarding_completed: false)
        expect(user.needs_onboarding?).to be true
      end

      it 'returns true when role is present but onboarding_completed is false' do
        user = create(:user, :mentee, onboarding_completed: false)
        expect(user.needs_onboarding?).to be true
      end

      it 'returns false when both role and onboarding_completed are set' do
        user = create(:user, :mentee, onboarding_completed: true)
        expect(user.needs_onboarding?).to be false
      end
    end

    describe 'role validation edge cases' do
      it 'allows nil role' do
        user = build(:user, role: nil)
        expect(user).to be_valid
      end

      it 'allows empty string role' do
        user = build(:user, role: '')
        expect(user).to be_valid
      end

      it 'rejects invalid role values' do
        user = build(:user, role: 'invalid')
        expect(user).not_to be_valid
        expect(user.errors[:role]).to include('is not included in the list')
      end
    end
  end
end

