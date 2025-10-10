require 'rails_helper'

RSpec.describe Profile, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'validations' do
    # Profile model currently has minimal validations
    # These tests document the current behavior

    it 'is valid with valid attributes' do
      profile = build(:profile, :complete)
      expect(profile).to be_valid
    end

    it 'is valid without optional fields' do
      profile = build(:profile, :without_urls)
      expect(profile).to be_valid
    end
  end

  describe 'mentor and mentee flags' do
    it 'can be a mentor only' do
      profile = create(:profile, :mentor)
      expect(profile.mentor).to be true
      expect(profile.mentee).to be false
    end

    it 'can be a mentee only' do
      profile = create(:profile, :mentee)
      expect(profile.mentor).to be false
      expect(profile.mentee).to be true
    end

    it 'can be both mentor and mentee' do
      profile = create(:profile, :both)
      expect(profile.mentor).to be true
      expect(profile.mentee).to be true
    end

    it 'defaults to neither mentor nor mentee' do
      profile = create(:profile)
      expect(profile.mentor).to be false
      expect(profile.mentee).to be false
    end
  end

  describe 'URL fields' do
    it 'accepts valid GitHub URLs' do
      profile = build(:profile, github_url: 'https://github.com/username')
      expect(profile).to be_valid
    end

    it 'accepts valid X (Twitter) URLs' do
      profile = build(:profile, x_url: 'https://x.com/username')
      expect(profile).to be_valid
    end

    it 'accepts valid website URLs' do
      profile = build(:profile, website_url: 'https://example.com')
      expect(profile).to be_valid
    end

    it 'allows nil URLs' do
      profile = build(:profile, github_url: nil, x_url: nil, website_url: nil)
      expect(profile).to be_valid
    end
  end

  describe 'experience levels' do
    it 'accepts zero years of experience' do
      profile = build(:profile, years_experience: 0)
      expect(profile).to be_valid
    end

    it 'accepts positive years of experience' do
      profile = build(:profile, years_experience: 10)
      expect(profile).to be_valid
    end

    it 'accepts large years of experience' do
      profile = build(:profile, years_experience: 30)
      expect(profile).to be_valid
    end
  end

  describe 'factory' do
    it 'has a valid default factory' do
      expect(build(:profile)).to be_valid
    end

    it 'creates a valid mentor profile' do
      profile = create(:profile, :mentor)
      expect(profile).to be_valid
      expect(profile.mentor).to be true
      expect(profile.years_experience).to be >= 5
    end

    it 'creates a valid mentee profile' do
      profile = create(:profile, :mentee)
      expect(profile).to be_valid
      expect(profile.mentee).to be true
      expect(profile.years_experience).to be <= 2
    end

    it 'creates a complete profile with all fields' do
      profile = create(:profile, :complete)
      expect(profile.name).to be_present
      expect(profile.bio).to be_present
      expect(profile.years_experience).to be_present
      expect(profile.timezone).to be_present
      expect(profile.skills).to be_present
      expect(profile.availability).to be_present
      expect(profile.github_url).to be_present
      expect(profile.x_url).to be_present
      expect(profile.website_url).to be_present
    end
  end

  describe 'association with user' do
    it 'belongs to a user' do
      user = create(:user)
      profile = create(:profile, user: user)
      expect(profile.user).to eq(user)
    end

    it 'is destroyed when user is destroyed' do
      user = create(:user, :with_profile)
      profile_id = user.profile.id

      user.destroy

      expect(Profile.find_by(id: profile_id)).to be_nil
    end

    it 'requires a user' do
      profile = build(:profile, user: nil)
      expect(profile).not_to be_valid
    end
  end

  describe 'data integrity' do
    it 'stores bio as text' do
      long_bio = 'A' * 1000
      profile = create(:profile, bio: long_bio)
      expect(profile.reload.bio).to eq(long_bio)
    end

    it 'stores availability as text' do
      long_availability = 'Available ' * 100
      profile = create(:profile, availability: long_availability)
      expect(profile.reload.availability).to eq(long_availability)
    end

    it 'preserves skills as comma-separated string' do
      skills = 'Ruby, Rails, JavaScript, PostgreSQL, Docker'
      profile = create(:profile, skills: skills)
      expect(profile.reload.skills).to eq(skills)
    end
  end

  describe 'edge cases' do
    describe 'boolean flags' do
      it 'allows both mentor and mentee to be true' do
        profile = build(:profile, mentor: true, mentee: true)
        expect(profile).to be_valid
      end

      it 'allows both mentor and mentee to be false' do
        profile = build(:profile, mentor: false, mentee: false)
        expect(profile).to be_valid
      end

      it 'defaults mentor and mentee to false' do
        profile = create(:profile)
        expect(profile.mentor).to be false
        expect(profile.mentee).to be false
      end
    end

    describe 'URL validations' do
      it 'accepts valid GitHub URLs' do
        profile = build(:profile, github_url: 'https://github.com/username')
        expect(profile).to be_valid
      end

      it 'accepts valid X URLs' do
        profile = build(:profile, x_url: 'https://x.com/username')
        expect(profile).to be_valid
      end

      it 'accepts valid website URLs' do
        profile = build(:profile, website_url: 'https://example.com')
        expect(profile).to be_valid
      end

      it 'accepts empty URLs' do
        profile = build(:profile, github_url: '', x_url: '', website_url: '')
        expect(profile).to be_valid
      end

      it 'accepts nil URLs' do
        profile = build(:profile, github_url: nil, x_url: nil, website_url: nil)
        expect(profile).to be_valid
      end
    end

    describe 'years_experience edge cases' do
      it 'accepts zero years of experience' do
        profile = build(:profile, years_experience: 0)
        expect(profile).to be_valid
      end

      it 'accepts nil years_experience' do
        profile = build(:profile, years_experience: nil)
        expect(profile).to be_valid
      end

      it 'accepts very high years of experience' do
        profile = build(:profile, years_experience: 50)
        expect(profile).to be_valid
      end
    end

    describe 'text field limits' do
      it 'handles very long names' do
        long_name = 'A' * 255
        profile = build(:profile, name: long_name)
        expect(profile).to be_valid
      end

      it 'handles empty strings for optional fields' do
        profile = build(:profile,
          name: '',
          bio: '',
          skills: '',
          availability: ''
        )
        expect(profile).to be_valid
      end

      it 'handles special characters in text fields' do
        profile = build(:profile,
          name: 'José María',
          bio: 'I love Ruby & Rails! 🚀',
          skills: 'Ruby, Rails, JavaScript & TypeScript'
        )
        expect(profile).to be_valid
      end
    end
  end
end

