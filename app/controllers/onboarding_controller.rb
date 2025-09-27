class OnboardingController < ApplicationController
  before_action :authenticate_user!
  before_action :redirect_if_onboarded, except: [:complete]

  def index
    # Welcome screen after signup
  end

  def choose_role
    # Role selection screen
  end

  def set_role
    @user = current_user

    if @user.update(user_params)
      case @user.role
      when 'mentee'
        redirect_to new_mentorship_request_path, notice: "Great! Let's create your first mentorship request."
      when 'mentor'
        redirect_to new_profile_path, notice: "Awesome! Let's set up your mentor profile."
      when 'both'
        redirect_to onboarding_complete_path, notice: "Perfect! You can now mentor others and request mentorship."
      end
    else
      redirect_to onboarding_choose_role_path, alert: "Please select a role to continue."
    end
  end

  def complete
    current_user.update(onboarding_completed: true) if current_user.role.present?
    # Final onboarding screen with next steps
  end

  private

  def user_params
    params.require(:user).permit(:role)
  end

  def redirect_if_onboarded
    if current_user.onboarding_completed? && current_user.role.present?
      redirect_to root_path
    end
  end
end