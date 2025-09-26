require "application_system_test_case"

class MentorshipRequestsTest < ApplicationSystemTestCase
  setup do
    @mentorship_request = mentorship_requests(:one)
  end

  test "visiting the index" do
    visit mentorship_requests_url
    assert_selector "h1", text: "Mentorship requests"
  end

  test "should create mentorship request" do
    visit mentorship_requests_url
    click_on "New mentorship request"

    fill_in "Goals", with: @mentorship_request.goals
    fill_in "Mentee", with: @mentorship_request.mentee_id
    fill_in "Mentor", with: @mentorship_request.mentor_id
    fill_in "Preferred times", with: @mentorship_request.preferred_times
    fill_in "Status", with: @mentorship_request.status
    fill_in "Topic", with: @mentorship_request.topic
    click_on "Create Mentorship request"

    assert_text "Mentorship request was successfully created"
    click_on "Back"
  end

  test "should update Mentorship request" do
    visit mentorship_request_url(@mentorship_request)
    click_on "Edit this mentorship request", match: :first

    fill_in "Goals", with: @mentorship_request.goals
    fill_in "Mentee", with: @mentorship_request.mentee_id
    fill_in "Mentor", with: @mentorship_request.mentor_id
    fill_in "Preferred times", with: @mentorship_request.preferred_times
    fill_in "Status", with: @mentorship_request.status
    fill_in "Topic", with: @mentorship_request.topic
    click_on "Update Mentorship request"

    assert_text "Mentorship request was successfully updated"
    click_on "Back"
  end

  test "should destroy Mentorship request" do
    visit mentorship_request_url(@mentorship_request)
    accept_confirm { click_on "Destroy this mentorship request", match: :first }

    assert_text "Mentorship request was successfully destroyed"
  end
end
