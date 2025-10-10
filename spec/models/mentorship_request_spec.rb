require 'rails_helper'

RSpec.describe MentorshipRequest, type: :model do
  describe 'associations' do
    it { should belong_to(:mentee).class_name('User') }
    it { should belong_to(:mentor).class_name('User').optional }
    it { should have_many(:messages).dependent(:destroy) }
    it { should have_many(:conversation_metadata).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:topic) }
    
    it 'is valid with valid attributes' do
      request = build(:mentorship_request)
      expect(request).to be_valid
    end

    it 'is invalid without a topic' do
      request = build(:mentorship_request, topic: nil)
      expect(request).not_to be_valid
    end

    it 'is valid without a mentor (open request)' do
      request = build(:mentorship_request, :open)
      expect(request).to be_valid
      expect(request.mentor).to be_nil
    end
  end

  describe 'status enum' do
    it { should define_enum_for(:status).with_values(open: 0, accepted: 1, closed: 2) }

    it 'defaults to open status' do
      request = create(:mentorship_request, :open)
      expect(request.status).to eq('open')
      expect(request.open?).to be true
    end

    it 'can be accepted' do
      request = create(:mentorship_request, :accepted)
      expect(request.status).to eq('accepted')
      expect(request.accepted?).to be true
    end

    it 'can be closed' do
      request = create(:mentorship_request, :closed)
      expect(request.status).to eq('closed')
      expect(request.closed?).to be true
    end

    it 'can transition from open to accepted' do
      request = create(:mentorship_request, :open)
      mentor = create(:user, :mentor)
      
      request.update!(status: :accepted, mentor: mentor)
      
      expect(request.accepted?).to be true
      expect(request.mentor).to eq(mentor)
    end

    it 'can transition from accepted to closed' do
      request = create(:mentorship_request, :accepted)
      
      request.update!(status: :closed)
      
      expect(request.closed?).to be true
    end
  end

  describe '#unread_count_for_user' do
    it 'returns count of unread messages for a user' do
      mentee = create(:user, :mentee)
      mentor = create(:user, :mentor)
      request = create(:mentorship_request, :accepted, mentee: mentee, mentor: mentor)
      
      # Create messages from mentor (unread by mentee)
      create(:message, :unread, mentorship_request: request, user: mentor)
      create(:message, :unread, mentorship_request: request, user: mentor)
      
      # Create message from mentee (should not count)
      create(:message, :unread, mentorship_request: request, user: mentee)
      
      expect(request.unread_count_for_user(mentee)).to eq(2)
    end

    it 'returns 0 when all messages are read' do
      mentee = create(:user, :mentee)
      mentor = create(:user, :mentor)
      request = create(:mentorship_request, :accepted, mentee: mentee, mentor: mentor)
      
      create(:message, :read, mentorship_request: request, user: mentor)
      
      expect(request.unread_count_for_user(mentee)).to eq(0)
    end

    it 'returns 0 when there are no messages' do
      request = create(:mentorship_request, :accepted)
      
      expect(request.unread_count_for_user(request.mentee)).to eq(0)
    end
  end

  describe '#users_typing_except' do
    it 'returns users who are typing except the current user' do
      mentee = create(:user, :mentee)
      mentor = create(:user, :mentor)
      request = create(:mentorship_request, :accepted, mentee: mentee, mentor: mentor)
      
      # Mentor is typing
      create(:conversation_metadata, :typing, mentorship_request: request, user: mentor)
      
      typing_users = request.users_typing_except(mentee)
      
      expect(typing_users).to include(mentor)
      expect(typing_users).not_to include(mentee)
    end

    it 'excludes current user even if they are typing' do
      mentee = create(:user, :mentee)
      mentor = create(:user, :mentor)
      request = create(:mentorship_request, :accepted, mentee: mentee, mentor: mentor)
      
      # Both are typing
      create(:conversation_metadata, :typing, mentorship_request: request, user: mentor)
      create(:conversation_metadata, :typing, mentorship_request: request, user: mentee)
      
      typing_users = request.users_typing_except(mentee)
      
      expect(typing_users).to include(mentor)
      expect(typing_users).not_to include(mentee)
    end

    it 'returns empty array when no one is typing' do
      request = create(:mentorship_request, :accepted)
      
      typing_users = request.users_typing_except(request.mentee)
      
      expect(typing_users).to be_empty
    end

    it 'excludes users who are not typing' do
      mentee = create(:user, :mentee)
      mentor = create(:user, :mentor)
      request = create(:mentorship_request, :accepted, mentee: mentee, mentor: mentor)
      
      # Mentor is NOT typing
      create(:conversation_metadata, :not_typing, mentorship_request: request, user: mentor)
      
      typing_users = request.users_typing_except(mentee)
      
      expect(typing_users).to be_empty
    end
  end

  describe 'factory' do
    it 'has a valid default factory' do
      expect(build(:mentorship_request)).to be_valid
    end

    it 'creates an open request without mentor' do
      request = create(:mentorship_request, :open)
      expect(request.open?).to be true
      expect(request.mentor).to be_nil
    end

    it 'creates an accepted request with mentor' do
      request = create(:mentorship_request, :accepted)
      expect(request.accepted?).to be true
      expect(request.mentor).to be_present
    end

    it 'creates a closed request' do
      request = create(:mentorship_request, :closed)
      expect(request.closed?).to be true
    end

    it 'creates request with messages using trait' do
      request = create(:mentorship_request, :with_messages)
      expect(request.messages.count).to be >= 3
    end

    it 'creates request with conversation using trait' do
      request = create(:mentorship_request, :with_conversation)
      expect(request.messages.count).to eq(3)
      expect(request.accepted?).to be true
    end
  end

  describe 'dependent destroy' do
    it 'destroys associated messages when request is destroyed' do
      request = create(:mentorship_request, :with_messages)
      message_ids = request.messages.pluck(:id)
      
      request.destroy
      
      message_ids.each do |id|
        expect(Message.find_by(id: id)).to be_nil
      end
    end

    it 'destroys associated conversation metadata when request is destroyed' do
      request = create(:mentorship_request, :accepted)
      metadata = create(:conversation_metadata, mentorship_request: request, user: request.mentee)
      metadata_id = metadata.id
      
      request.destroy
      
      expect(ConversationMetadata.find_by(id: metadata_id)).to be_nil
    end
  end

  describe 'participants' do
    it 'has a mentee' do
      request = create(:mentorship_request)
      expect(request.mentee).to be_present
      expect(request.mentee).to be_a(User)
    end

    it 'can have a mentor' do
      request = create(:mentorship_request, :accepted)
      expect(request.mentor).to be_present
      expect(request.mentor).to be_a(User)
    end

    it 'mentee and mentor are different users' do
      request = create(:mentorship_request, :accepted)
      expect(request.mentee).not_to eq(request.mentor)
    end
  end

  describe 'data integrity' do
    it 'stores goals as text' do
      long_goals = 'Goal ' * 500
      request = create(:mentorship_request, goals: long_goals)
      expect(request.reload.goals).to eq(long_goals)
    end

    it 'preserves topic' do
      topic = 'Learning Ruby on Rails Testing Best Practices'
      request = create(:mentorship_request, topic: topic)
      expect(request.reload.topic).to eq(topic)
    end

    it 'preserves preferred times' do
      times = 'Monday-Friday 6-9pm EST, Saturdays 10am-2pm EST'
      request = create(:mentorship_request, preferred_times: times)
      expect(request.reload.preferred_times).to eq(times)
    end
  end
end

