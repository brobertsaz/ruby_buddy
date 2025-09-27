require "test_helper"

class Api::TypingIndicatorControllerTest < ActionDispatch::IntegrationTest
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

  test "should start typing indicator" do
    sign_in @user

    post "/api/mentorship_requests/#{@mentorship_request.id}/typing", params: {
      typing: true
    }

    assert_response :success

    metadata = ConversationMetadata.find_by(
      user: @user,
      mentorship_request: @mentorship_request
    )
    assert metadata.typing?

    json_response = JSON.parse(response.body)
    assert_equal "Typing status updated", json_response["message"]
    assert json_response["typing"]
  end

  test "should stop typing indicator" do
    # First create a typing indicator
    ConversationMetadata.create!(
      user: @user,
      mentorship_request: @mentorship_request,
      typing: true
    )

    sign_in @user

    post "/api/mentorship_requests/#{@mentorship_request.id}/typing", params: {
      typing: false
    }

    assert_response :success

    metadata = ConversationMetadata.find_by(
      user: @user,
      mentorship_request: @mentorship_request
    )
    assert_not metadata.typing?

    json_response = JSON.parse(response.body)
    assert_equal "Typing status updated", json_response["message"]
    assert_not json_response["typing"]
  end

  test "should get typing users for mentorship request" do
    # Create typing indicator for mentor
    ConversationMetadata.create!(
      user: @mentor,
      mentorship_request: @mentorship_request,
      typing: true
    )

    sign_in @user

    get "/api/mentorship_requests/#{@mentorship_request.id}/typing"

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal 1, json_response["typing_users"].length
    assert_equal @mentor.email, json_response["typing_users"].first["email"]
  end

  test "should not include current user in typing users list" do
    # Both users typing
    ConversationMetadata.create!(
      user: @user,
      mentorship_request: @mentorship_request,
      typing: true
    )
    ConversationMetadata.create!(
      user: @mentor,
      mentorship_request: @mentorship_request,
      typing: true
    )

    sign_in @user

    get "/api/mentorship_requests/#{@mentorship_request.id}/typing"

    assert_response :success
    json_response = JSON.parse(response.body)
    # Should only see mentor typing, not self
    assert_equal 1, json_response["typing_users"].length
    assert_equal @mentor.email, json_response["typing_users"].first["email"]
  end

  test "should cleanup expired typing indicators" do
    # Create old typing indicator
    old_metadata = ConversationMetadata.create!(
      user: @mentor,
      mentorship_request: @mentorship_request,
      typing: true,
      typing_updated_at: 10.seconds.ago
    )

    sign_in @user

    post "/api/typing/cleanup"

    assert_response :success
    old_metadata.reload
    assert_not old_metadata.typing?

    json_response = JSON.parse(response.body)
    assert_equal "Expired typing indicators cleaned up", json_response["message"]
  end

  test "should require authentication for typing endpoints" do
    post "/api/mentorship_requests/#{@mentorship_request.id}/typing"
    assert_response :unauthorized

    get "/api/mentorship_requests/#{@mentorship_request.id}/typing"
    assert_response :unauthorized
  end

  test "should not allow access to other users mentorship requests" do
    other_user = User.create!(email: "other@example.com", password: "password123")
    other_request = MentorshipRequest.create!(
      mentee: other_user,
      mentor: @mentor,
      topic: "Other topic",
      goals: "Other goals"
    )

    sign_in @user

    post "/api/mentorship_requests/#{other_request.id}/typing", params: { typing: true }
    assert_response :forbidden

    get "/api/mentorship_requests/#{other_request.id}/typing"
    assert_response :forbidden
  end

  test "should handle typing for messages endpoint" do
    message = Message.create!(
      user: @mentor,
      mentorship_request: @mentorship_request,
      body: "Test message"
    )

    sign_in @user

    post "/api/messages/typing", params: {
      mentorship_request_id: @mentorship_request.id,
      typing: true
    }

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal "Typing status updated", json_response["message"]
  end

  private

  def sign_in(user)
    post user_session_path, params: {
      user: { email: user.email, password: "password123" }
    }
  end
end