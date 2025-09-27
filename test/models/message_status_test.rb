require "test_helper"

class MessageStatusTest < ActiveSupport::TestCase
  self.use_transactional_tests = true
  def setup
    @user = User.create!(email: "test@example.com", password: "password123")
    @mentor = User.create!(email: "mentor@example.com", password: "password123")
    @mentorship_request = MentorshipRequest.create!(
      mentee: @user,
      mentor: @mentor,
      topic: "Ruby on Rails",
      goals: "Learn the basics"
    )
  end

  test "message automatically sets sent_at on creation" do
    message = Message.create!(
      user: @user,
      mentorship_request: @mentorship_request,
      body: "Hello, world!"
    )

    assert_not_nil message.sent_at
    assert message.sent_at <= Time.current
    assert message.sent?
    assert_not message.read?
  end

  test "message can be marked as read" do
    message = Message.create!(
      user: @user,
      mentorship_request: @mentorship_request,
      body: "Test message"
    )

    original_sent_at = message.sent_at
    message.mark_as_read!

    assert message.read?
    assert_not_nil message.read_at
    assert message.read_at >= message.sent_at
    assert_equal original_sent_at, message.sent_at
  end

  test "message scopes work correctly" do
    sent_message = Message.create!(
      user: @user,
      mentorship_request: @mentorship_request,
      body: "Sent message"
    )

    read_message = Message.create!(
      user: @mentor,
      mentorship_request: @mentorship_request,
      body: "Read message"
    )
    read_message.mark_as_read!

    assert_includes Message.sent, sent_message
    assert_includes Message.sent, read_message
    assert_includes Message.read, read_message
    assert_not_includes Message.read, sent_message
    assert_includes Message.unread, sent_message
    assert_not_includes Message.unread, read_message
  end

  test "unread count for request works" do
    3.times do |i|
      Message.create!(
        user: @mentor,
        mentorship_request: @mentorship_request,
        body: "Message #{i}"
      )
    end

    assert_equal 3, Message.unread_count_for_request(@mentorship_request.id)
    assert_equal 3, @mentorship_request.unread_count_for_user(@user)
  end
end