require "test_helper"

class OnboardingControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get onboarding_index_url
    assert_response :success
  end

  test "should get choose_role" do
    get onboarding_choose_role_url
    assert_response :success
  end

  test "should get set_role" do
    get onboarding_set_role_url
    assert_response :success
  end

  test "should get complete" do
    get onboarding_complete_url
    assert_response :success
  end
end
