require "test_helper"

class Api::MessageStatusControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(email: "test@example.com", password: "password123")
    @mentor = User.create!(email: "mentor@example.com", password: "password123")
    @mentorship_request = MentorshipRequest.create!(
      mentee: @user,
      mentor: @mentor,
      topic: "Ruby on Rails",
      goals: "Learn the basics"
    )
    @message = Message.create!(
      user: @mentor,
      mentorship_request: @mentorship_request,
      body: "Hello, let's get started!"
    )
  end

  test "should mark message as read" do
    sign_in @user

    post "/api/messages/#{@message.id}/mark_read"

    assert_response :success
    @message.reload
    assert @message.read?

    json_response = JSON.parse(response.body)
    assert_equal "Message marked as read", json_response["message"]
    assert_not_nil json_response["read_at"]
  end

  test "should not mark already read message" do
    @message.mark_as_read!
    sign_in @user

    post "/api/messages/#{@message.id}/mark_read"

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal "Message already read", json_response["message"]
  end

  test "should get message status" do
    @message.mark_as_read!
    sign_in @user

    get "/api/messages/#{@message.id}/status"

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal "read", json_response["status"]
    assert_not_nil json_response["sent_at"]
    assert_not_nil json_response["read_at"]
  end

  test "should bulk mark messages as read" do
    message2 = Message.create!(
      user: @mentor,
      mentorship_request: @mentorship_request,
      body: "Another message"
    )

    sign_in @user

    post "/api/messages/bulk_mark_read", params: {
      message_ids: [@message.id, message2.id]
    }

    assert_response :success
    @message.reload
    message2.reload
    assert @message.read?
    assert message2.read?

    json_response = JSON.parse(response.body)
    assert_equal 2, json_response["marked_count"]
  end

  test "should require authentication" do
    post "/api/messages/#{@message.id}/mark_read"
    assert_response :unauthorized
  end

  test "should not allow marking others' received messages" do
    # User shouldn't be able to mark their own sent messages as read
    own_message = Message.create!(
      user: @user,
      mentorship_request: @mentorship_request,
      body: "My message"
    )

    sign_in @user

    post "/api/messages/#{own_message.id}/mark_read"
    assert_response :forbidden
  end

  test "should not allow access to messages from other mentorship requests" do
    other_user = User.create!(email: "other@example.com", password: "password123")
    other_request = MentorshipRequest.create!(
      mentee: other_user,
      mentor: @mentor,
      topic: "Other topic",
      goals: "Other goals"
    )
    other_message = Message.create!(
      user: @mentor,
      mentorship_request: other_request,
      body: "Message for other user"
    )

    sign_in @user

    post "/api/messages/#{other_message.id}/mark_read"
    assert_response :forbidden
  end

  private

  def sign_in(user)
    post user_session_path, params: {
      user: { email: user.email, password: "password123" }
    }
  end
end