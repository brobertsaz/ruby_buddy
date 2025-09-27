require "test_helper"

class ConversationMetadataTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @mentor = users(:two)
    @mentorship_request = mentorship_requests(:one)
  end

  test "conversation_metadata should be valid" do
    metadata = ConversationMetadata.new(
      mentorship_request: @mentorship_request,
      user: @user,
      typing: false
    )
    assert metadata.valid?
  end

  test "conversation_metadata requires mentorship_request" do
    metadata = ConversationMetadata.new(user: @user, typing: false)
    assert_not metadata.valid?
  end

  test "conversation_metadata requires user" do
    metadata = ConversationMetadata.new(
      mentorship_request: @mentorship_request,
      typing: false
    )
    assert_not metadata.valid?
  end

  test "typing should default to false" do
    metadata = ConversationMetadata.create!(
      mentorship_request: @mentorship_request,
      user: @user
    )
    assert_not metadata.typing?
  end

  test "can set typing status to true" do
    metadata = ConversationMetadata.create!(
      mentorship_request: @mentorship_request,
      user: @user,
      typing: true
    )
    assert metadata.typing?
  end

  test "typing_updated_at should be set when typing status changes" do
    metadata = ConversationMetadata.create!(
      mentorship_request: @mentorship_request,
      user: @user,
      typing: false
    )

    original_time = metadata.typing_updated_at
    sleep 0.01 # Small delay to ensure time difference

    metadata.update!(typing: true)
    assert metadata.typing_updated_at > original_time
  end

  test "find_or_initialize_for_user_and_request creates new record if none exists" do
    # Ensure no existing metadata
    ConversationMetadata.where(
      user: @user,
      mentorship_request: @mentorship_request
    ).destroy_all

    metadata = ConversationMetadata.find_or_initialize_for_user_and_request(@user, @mentorship_request)
    assert metadata.new_record?
    assert_equal @user, metadata.user
    assert_equal @mentorship_request, metadata.mentorship_request
  end

  test "find_or_initialize_for_user_and_request finds existing record" do
    existing_metadata = ConversationMetadata.create!(
      mentorship_request: @mentorship_request,
      user: @user,
      typing: true
    )

    metadata = ConversationMetadata.find_or_initialize_for_user_and_request(@user, @mentorship_request)
    assert_not metadata.new_record?
    assert_equal existing_metadata.id, metadata.id
    assert metadata.typing?
  end

  test "typing_for_request scope returns users typing in specific request" do
    # Create typing indicators for different users
    typing_user = ConversationMetadata.create!(
      mentorship_request: @mentorship_request,
      user: @user,
      typing: true
    )

    not_typing_user = ConversationMetadata.create!(
      mentorship_request: @mentorship_request,
      user: @mentor,
      typing: false
    )

    typing_users = ConversationMetadata.typing_for_request(@mentorship_request.id)
    assert_includes typing_users, typing_user
    assert_not_includes typing_users, not_typing_user
  end

  test "should clean up expired typing indicators" do
    # Create an old typing indicator
    old_typing = ConversationMetadata.create!(
      mentorship_request: @mentorship_request,
      user: @user,
      typing: true,
      typing_updated_at: 10.seconds.ago
    )

    # Create a recent typing indicator
    recent_typing = ConversationMetadata.create!(
      mentorship_request: @mentorship_request,
      user: @mentor,
      typing: true,
      typing_updated_at: 1.second.ago
    )

    ConversationMetadata.cleanup_expired_typing_indicators

    old_typing.reload
    recent_typing.reload

    assert_not old_typing.typing?
    assert recent_typing.typing?
  end
end
