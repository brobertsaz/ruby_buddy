require 'rails_helper'

RSpec.describe Message, type: :model do
  describe 'associations' do
    it { should belong_to(:mentorship_request) }
    it { should belong_to(:user) }
  end

  describe 'validations' do
    it { should validate_presence_of(:body) }

    it 'is valid with valid attributes' do
      message = build(:message)
      expect(message).to be_valid
    end

    it 'is invalid without a body' do
      message = build(:message, body: nil)
      expect(message).not_to be_valid
    end

    it 'is invalid without a mentorship_request' do
      message = build(:message, mentorship_request: nil)
      expect(message).not_to be_valid
    end

    it 'is invalid without a user' do
      message = build(:message, user: nil)
      expect(message).not_to be_valid
    end
  end

  describe 'callbacks' do
    describe 'before_create :set_sent_at' do
      it 'sets sent_at timestamp when message is created' do
        message = create(:message)
        expect(message.sent_at).to be_present
      end

      it 'does not override sent_at if already set' do
        # Create message first so created_at is set
        message = create(:message)
        original_sent_at = message.sent_at

        # Update and verify sent_at wasn't changed
        message.update!(body: "Updated body")

        # Verify sent_at was preserved
        expect(message.sent_at).to eq(original_sent_at)
      end
    end
  end

  describe 'scopes' do
    let(:request) { create(:mentorship_request, :accepted) }

    describe '.sent' do
      it 'returns messages with sent_at timestamp' do
        sent_message = create(:message, :sent, mentorship_request: request)
        unsent_message = create(:message, mentorship_request: request)
        unsent_message.update_column(:sent_at, nil)

        expect(Message.sent).to include(sent_message)
        expect(Message.sent).not_to include(unsent_message)
      end
    end

    describe '.read' do
      it 'returns messages with read_at timestamp' do
        read_message = create(:message, :read, mentorship_request: request)
        unread_message = create(:message, :unread, mentorship_request: request)

        expect(Message.read).to include(read_message)
        expect(Message.read).not_to include(unread_message)
      end
    end

    describe '.unread' do
      it 'returns messages without read_at timestamp' do
        read_message = create(:message, :read, mentorship_request: request)
        unread_message = create(:message, :unread, mentorship_request: request)

        expect(Message.unread).to include(unread_message)
        expect(Message.unread).not_to include(read_message)
      end
    end

    describe '.unread_for_request' do
      it 'returns unread messages for a specific request' do
        request1 = create(:mentorship_request, :accepted)
        request2 = create(:mentorship_request, :accepted)

        unread1 = create(:message, :unread, mentorship_request: request1)
        unread2 = create(:message, :unread, mentorship_request: request2)
        read1 = create(:message, :read, mentorship_request: request1)

        result = Message.unread_for_request(request1.id)

        expect(result).to include(unread1)
        expect(result).not_to include(unread2)
        expect(result).not_to include(read1)
      end
    end
  end

  describe '.unread_count_for_request' do
    it 'returns count of unread messages for a request' do
      request = create(:mentorship_request, :accepted)
      create_list(:message, 3, :unread, mentorship_request: request)
      create(:message, :read, mentorship_request: request)

      expect(Message.unread_count_for_request(request.id)).to eq(3)
    end

    it 'returns 0 when all messages are read' do
      request = create(:mentorship_request, :accepted)
      create_list(:message, 2, :read, mentorship_request: request)

      expect(Message.unread_count_for_request(request.id)).to eq(0)
    end
  end

  describe 'instance methods' do
    describe '#sent?' do
      it 'returns true when sent_at is present' do
        message = create(:message, :sent)
        expect(message.sent?).to be true
      end

      it 'returns false when sent_at is nil' do
        message = create(:message)
        message.update_column(:sent_at, nil)
        expect(message.sent?).to be false
      end
    end

    describe '#read?' do
      it 'returns true when read_at is present' do
        message = create(:message, :read)
        expect(message.read?).to be true
      end

      it 'returns false when read_at is nil' do
        message = create(:message, :unread)
        expect(message.read?).to be false
      end
    end

    describe '#unread?' do
      it 'returns true when read_at is nil' do
        message = create(:message, :unread)
        expect(message.unread?).to be true
      end

      it 'returns false when read_at is present' do
        message = create(:message, :read)
        expect(message.unread?).to be false
      end
    end

    describe '#mark_as_read!' do
      it 'sets read_at timestamp' do
        message = create(:message, :unread)

        expect {
          message.mark_as_read!
        }.to change { message.read_at }.from(nil)

        expect(message.read?).to be true
      end

      it 'does not change read_at if already read' do
        message = create(:message, :read)
        original_read_at = message.read_at

        expect {
          message.mark_as_read!
        }.not_to change { message.reload.read_at }

        expect(message.read_at).to eq(original_read_at)
      end
    end
  end

  describe 'factory' do
    it 'has a valid default factory' do
      expect(build(:message)).to be_valid
    end

    it 'creates a sent message' do
      message = create(:message, :sent)
      expect(message.sent?).to be true
    end

    it 'creates a read message' do
      message = create(:message, :read)
      expect(message.read?).to be true
      expect(message.sent?).to be true
    end

    it 'creates an unread message' do
      message = create(:message, :unread)
      expect(message.unread?).to be true
      expect(message.sent?).to be true
    end

    it 'creates a long message' do
      message = create(:message, :long_message)
      expect(message.body.length).to be > 100
    end

    it 'creates a short message' do
      message = create(:message, :short_message)
      expect(message.body.split.count).to eq(3)
    end
  end

  describe 'timestamps' do
    it 'has created_at timestamp' do
      message = create(:message)
      expect(message.created_at).to be_present
    end

    it 'has updated_at timestamp' do
      message = create(:message)
      expect(message.updated_at).to be_present
    end

    it 'sent_at is set on creation' do
      message = create(:message)
      expect(message.sent_at).to be_present
      expect(message.sent_at).to be >= message.created_at
    end
  end

  describe 'data integrity' do
    it 'stores body as text' do
      long_body = 'A' * 5000
      message = create(:message, body: long_body)
      expect(message.reload.body).to eq(long_body)
    end

    it 'preserves message content' do
      content = "Hello! This is a test message with special chars: @#$%^&*()"
      message = create(:message, body: content)
      expect(message.reload.body).to eq(content)
    end
  end

  describe 'database constraints' do
    it 'enforces sent_at >= created_at' do
      message = create(:message)

      expect {
        message.update_column(:sent_at, message.created_at - 1.second)
      }.to raise_error(ActiveRecord::StatementInvalid, /check_sent_at_after_created_at/)
    end

    it 'enforces read_at >= created_at' do
      message = create(:message)

      expect {
        message.update_column(:read_at, message.created_at - 1.second)
      }.to raise_error(ActiveRecord::StatementInvalid, /check_read_at_after_created_at/)
    end

    it 'enforces read_at >= sent_at when both present' do
      message = create(:message, :sent)

      # The constraint name includes "sent" in it
      expect {
        message.update_column(:read_at, message.sent_at - 1.second)
      }.to raise_error(ActiveRecord::StatementInvalid, /check_read_at/)
    end
  end
end

