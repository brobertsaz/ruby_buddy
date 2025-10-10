require 'rails_helper'

RSpec.describe ConversationMetadata, type: :model do
  describe 'associations' do
    it { should belong_to(:mentorship_request) }
    it { should belong_to(:user) }
  end

  describe 'validations' do
    it { should allow_value(true).for(:typing) }
    it { should allow_value(false).for(:typing) }
    it { should_not allow_value(nil).for(:typing) }
    
    it 'is valid with valid attributes' do
      metadata = build(:conversation_metadata)
      expect(metadata).to be_valid
    end
  end

  describe 'callbacks' do
    describe 'before_update :update_typing_timestamp' do
      it 'updates typing_updated_at when typing changes to true' do
        metadata = create(:conversation_metadata, :not_typing)
        old_timestamp = metadata.typing_updated_at
        
        sleep 0.01 # Ensure time difference
        metadata.update!(typing: true)
        
        expect(metadata.typing_updated_at).to be > old_timestamp
      end

      it 'updates typing_updated_at when typing changes to false' do
        metadata = create(:conversation_metadata, :typing)
        old_timestamp = metadata.typing_updated_at
        
        sleep 0.01 # Ensure time difference
        metadata.update!(typing: false)
        
        expect(metadata.typing_updated_at).to be > old_timestamp
      end

      it 'does not update typing_updated_at when typing does not change' do
        metadata = create(:conversation_metadata, :typing)
        old_timestamp = metadata.typing_updated_at
        
        metadata.update!(mentorship_request: metadata.mentorship_request)
        
        expect(metadata.typing_updated_at).to eq(old_timestamp)
      end
    end
  end

  describe 'scopes' do
    describe '.typing_for_request' do
      it 'returns typing metadata for a specific request' do
        request1 = create(:mentorship_request, :accepted)
        request2 = create(:mentorship_request, :accepted)
        
        typing1 = create(:conversation_metadata, :typing, mentorship_request: request1)
        typing2 = create(:conversation_metadata, :typing, mentorship_request: request2)
        not_typing1 = create(:conversation_metadata, :not_typing, mentorship_request: request1)
        
        result = ConversationMetadata.typing_for_request(request1.id)
        
        expect(result).to include(typing1)
        expect(result).not_to include(typing2)
        expect(result).not_to include(not_typing1)
      end

      it 'returns empty when no one is typing' do
        request = create(:mentorship_request, :accepted)
        create(:conversation_metadata, :not_typing, mentorship_request: request)
        
        result = ConversationMetadata.typing_for_request(request.id)
        
        expect(result).to be_empty
      end
    end
  end

  describe '.find_or_initialize_for_user_and_request' do
    it 'finds existing metadata for user and request' do
      user = create(:user, :mentee)
      request = create(:mentorship_request, :accepted, mentee: user)
      existing = create(:conversation_metadata, user: user, mentorship_request: request)
      
      result = ConversationMetadata.find_or_initialize_for_user_and_request(user, request)
      
      expect(result).to eq(existing)
      expect(result).to be_persisted
    end

    it 'initializes new metadata when none exists' do
      user = create(:user, :mentee)
      request = create(:mentorship_request, :accepted, mentee: user)
      
      result = ConversationMetadata.find_or_initialize_for_user_and_request(user, request)
      
      expect(result).to be_new_record
      expect(result.user).to eq(user)
      expect(result.mentorship_request).to eq(request)
    end
  end

  describe '.cleanup_expired_typing_indicators' do
    it 'sets typing to false for expired indicators' do
      stale = create(:conversation_metadata, :stale)
      
      ConversationMetadata.cleanup_expired_typing_indicators(5.seconds)
      
      expect(stale.reload.typing).to be false
    end

    it 'does not affect recent typing indicators' do
      recent = create(:conversation_metadata, :typing)
      
      ConversationMetadata.cleanup_expired_typing_indicators(5.seconds)
      
      expect(recent.reload.typing).to be true
    end

    it 'does not affect non-typing metadata' do
      not_typing = create(:conversation_metadata, :not_typing)
      
      ConversationMetadata.cleanup_expired_typing_indicators(5.seconds)
      
      expect(not_typing.reload.typing).to be false
    end

    it 'uses custom timeout' do
      # Create metadata that's 3 seconds old
      metadata = create(:conversation_metadata, typing: true)
      metadata.update_column(:typing_updated_at, 3.seconds.ago)
      
      # Should not clean up with 5 second timeout
      ConversationMetadata.cleanup_expired_typing_indicators(5.seconds)
      expect(metadata.reload.typing).to be true
      
      # Should clean up with 2 second timeout
      ConversationMetadata.cleanup_expired_typing_indicators(2.seconds)
      expect(metadata.reload.typing).to be false
    end

    it 'returns count of updated records' do
      create_list(:conversation_metadata, 3, :stale)
      create(:conversation_metadata, :typing)
      
      count = ConversationMetadata.cleanup_expired_typing_indicators(5.seconds)
      
      expect(count).to eq(3)
    end
  end

  describe 'factory' do
    it 'has a valid default factory' do
      expect(build(:conversation_metadata)).to be_valid
    end

    it 'creates typing metadata' do
      metadata = create(:conversation_metadata, :typing)
      expect(metadata.typing).to be true
      expect(metadata.typing_updated_at).to be_present
    end

    it 'creates not typing metadata' do
      metadata = create(:conversation_metadata, :not_typing)
      expect(metadata.typing).to be false
    end

    it 'creates stale metadata' do
      metadata = create(:conversation_metadata, :stale)
      expect(metadata.typing).to be true
      expect(metadata.typing_updated_at).to be < 5.seconds.ago
    end
  end

  describe 'data integrity' do
    it 'belongs to a mentorship request' do
      request = create(:mentorship_request, :accepted)
      metadata = create(:conversation_metadata, mentorship_request: request)
      
      expect(metadata.mentorship_request).to eq(request)
    end

    it 'belongs to a user' do
      user = create(:user, :mentee)
      metadata = create(:conversation_metadata, user: user)
      
      expect(metadata.user).to eq(user)
    end

    it 'stores typing as boolean' do
      metadata = create(:conversation_metadata, typing: true)
      expect(metadata.typing).to be_in([true, false])
    end

    it 'stores typing_updated_at as timestamp' do
      metadata = create(:conversation_metadata)
      expect(metadata.typing_updated_at).to be_a(ActiveSupport::TimeWithZone)
    end
  end

  describe 'table name' do
    it 'uses conversation_metadata as table name' do
      expect(ConversationMetadata.table_name).to eq('conversation_metadata')
    end
  end

  describe 'uniqueness' do
    it 'allows one metadata per user per request' do
      user = create(:user, :mentee)
      request = create(:mentorship_request, :accepted, mentee: user)
      
      create(:conversation_metadata, user: user, mentorship_request: request)
      duplicate = build(:conversation_metadata, user: user, mentorship_request: request)
      
      # Database has unique index, so this should raise an error
      expect { duplicate.save! }.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it 'allows same user in different requests' do
      user = create(:user, :mentee)
      request1 = create(:mentorship_request, :accepted, mentee: user)
      request2 = create(:mentorship_request, :accepted, mentee: user)
      
      metadata1 = create(:conversation_metadata, user: user, mentorship_request: request1)
      metadata2 = create(:conversation_metadata, user: user, mentorship_request: request2)
      
      expect(metadata1).to be_valid
      expect(metadata2).to be_valid
    end

    it 'allows different users in same request' do
      request = create(:mentorship_request, :accepted)
      user1 = request.mentee
      user2 = request.mentor
      
      metadata1 = create(:conversation_metadata, user: user1, mentorship_request: request)
      metadata2 = create(:conversation_metadata, user: user2, mentorship_request: request)
      
      expect(metadata1).to be_valid
      expect(metadata2).to be_valid
    end
  end
end

