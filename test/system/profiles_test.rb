require "application_system_test_case"

class ProfilesTest < ApplicationSystemTestCase
  setup do
    @profile = profiles(:one)
  end

  test "visiting the index" do
    visit profiles_url
    assert_selector "h1", text: "Profiles"
  end

  test "should create profile" do
    visit profiles_url
    click_on "New profile"

    fill_in "Availability", with: @profile.availability
    fill_in "Bio", with: @profile.bio
    fill_in "Github url", with: @profile.github_url
    check "Mentee" if @profile.mentee
    check "Mentor" if @profile.mentor
    fill_in "Name", with: @profile.name
    fill_in "Skills", with: @profile.skills
    fill_in "Timezone", with: @profile.timezone
    fill_in "User", with: @profile.user_id
    fill_in "Website url", with: @profile.website_url
    fill_in "X url", with: @profile.x_url
    fill_in "Years experience", with: @profile.years_experience
    click_on "Create Profile"

    assert_text "Profile was successfully created"
    click_on "Back"
  end

  test "should update Profile" do
    visit profile_url(@profile)
    click_on "Edit this profile", match: :first

    fill_in "Availability", with: @profile.availability
    fill_in "Bio", with: @profile.bio
    fill_in "Github url", with: @profile.github_url
    check "Mentee" if @profile.mentee
    check "Mentor" if @profile.mentor
    fill_in "Name", with: @profile.name
    fill_in "Skills", with: @profile.skills
    fill_in "Timezone", with: @profile.timezone
    fill_in "User", with: @profile.user_id
    fill_in "Website url", with: @profile.website_url
    fill_in "X url", with: @profile.x_url
    fill_in "Years experience", with: @profile.years_experience
    click_on "Update Profile"

    assert_text "Profile was successfully updated"
    click_on "Back"
  end

  test "should destroy Profile" do
    visit profile_url(@profile)
    accept_confirm { click_on "Destroy this profile", match: :first }

    assert_text "Profile was successfully destroyed"
  end
end
