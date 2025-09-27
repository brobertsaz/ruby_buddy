require "test_helper"

class MessageTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @mentor = users(:two)
    @mentorship_request = mentorship_requests(:one)
    @message = messages(:one)
  end

  test "message should be valid" do
    assert @message.valid?
  end

  test "message requires body" do
    @message.body = nil
    assert_not @message.valid?
  end

  test "message requires user" do
    @message.user = nil
    assert_not @message.valid?
  end

  test "message requires mentorship_request" do
    @message.mentorship_request = nil
    assert_not @message.valid?
  end

  # Message Status Tests
  test "message should have sent_at timestamp after creation" do
    new_message = Message.create!(
      user: @user,
      mentorship_request: @mentorship_request,
      body: "Test message"
    )
    assert_not_nil new_message.sent_at
    assert new_message.sent_at <= Time.current
  end

  test "message should be marked as sent by default" do
    new_message = Message.create!(
      user: @user,
      mentorship_request: @mentorship_request,
      body: "Test message"
    )
    assert new_message.sent?
    assert_not new_message.read?
  end

  test "message can be marked as read" do
    @message.mark_as_read!
    assert @message.read?
    assert_not_nil @message.read_at
    assert @message.read_at <= Time.current
  end

  test "read_at should be after sent_at" do
    @message.mark_as_read!
    assert @message.read_at >= @message.sent_at
  end

  test "sent scope returns only sent messages" do
    sent_messages = Message.sent
    sent_messages.each do |message|
      assert message.sent?
    end
  end

  test "read scope returns only read messages" do
    @message.mark_as_read!
    read_messages = Message.read
    assert_includes read_messages, @message
  end

  test "unread scope returns only unread messages" do
    unread_message = Message.create!(
      user: @user,
      mentorship_request: @mentorship_request,
      body: "Unread message"
    )
    unread_messages = Message.unread
    assert_includes unread_messages, unread_message
    assert_not_includes unread_messages, @message if @message.read?
  end

  test "unread_count_for_request returns correct count" do
    # Create additional unread messages
    3.times do |i|
      Message.create!(
        user: @mentor,
        mentorship_request: @mentorship_request,
        body: "Unread message #{i}"
      )
    end

    unread_count = Message.unread_count_for_request(@mentorship_request.id)
    assert unread_count >= 3
  end

  test "mark_as_read should not change sent_at" do
    original_sent_at = @message.sent_at
    @message.mark_as_read!
    assert_equal original_sent_at, @message.sent_at
  end

  test "message status should persist after reload" do
    @message.mark_as_read!
    @message.reload
    assert @message.read?
    assert_not_nil @message.read_at
  end
end
