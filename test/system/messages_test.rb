require "application_system_test_case"

class MessagesTest < ApplicationSystemTestCase
  setup do
    @message = messages(:one)
  end

  test "visiting the index" do
    visit messages_url
    assert_selector "h1", text: "Messages"
  end

  test "should create message" do
    visit messages_url
    click_on "New message"

    fill_in "Body", with: @message.body
    fill_in "Mentorship request", with: @message.mentorship_request_id
    fill_in "User", with: @message.user_id
    click_on "Create Message"

    assert_text "Message was successfully created"
    click_on "Back"
  end

  test "should update Message" do
    visit message_url(@message)
    click_on "Edit this message", match: :first

    fill_in "Body", with: @message.body
    fill_in "Mentorship request", with: @message.mentorship_request_id
    fill_in "User", with: @message.user_id
    click_on "Update Message"

    assert_text "Message was successfully updated"
    click_on "Back"
  end

  test "should destroy Message" do
    visit message_url(@message)
    accept_confirm { click_on "Destroy this message", match: :first }

    assert_text "Message was successfully destroyed"
  end
end
