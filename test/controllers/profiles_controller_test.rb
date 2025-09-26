require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @profile = profiles(:one)
  end

  test "should get index" do
    get profiles_url
    assert_response :success
  end

  test "should get new" do
    get new_profile_url
    assert_response :success
  end

  test "should create profile" do
    assert_difference("Profile.count") do
      post profiles_url, params: { profile: { availability: @profile.availability, bio: @profile.bio, github_url: @profile.github_url, mentee: @profile.mentee, mentor: @profile.mentor, name: @profile.name, skills: @profile.skills, timezone: @profile.timezone, user_id: @profile.user_id, website_url: @profile.website_url, x_url: @profile.x_url, years_experience: @profile.years_experience } }
    end

    assert_redirected_to profile_url(Profile.last)
  end

  test "should show profile" do
    get profile_url(@profile)
    assert_response :success
  end

  test "should get edit" do
    get edit_profile_url(@profile)
    assert_response :success
  end

  test "should update profile" do
    patch profile_url(@profile), params: { profile: { availability: @profile.availability, bio: @profile.bio, github_url: @profile.github_url, mentee: @profile.mentee, mentor: @profile.mentor, name: @profile.name, skills: @profile.skills, timezone: @profile.timezone, user_id: @profile.user_id, website_url: @profile.website_url, x_url: @profile.x_url, years_experience: @profile.years_experience } }
    assert_redirected_to profile_url(@profile)
  end

  test "should destroy profile" do
    assert_difference("Profile.count", -1) do
      delete profile_url(@profile)
    end

    assert_redirected_to profiles_url
  end
end
