class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # Temporarily disabled to allow all browsers during development
  # allow_browser versions: :modern

  before_action :redirect_to_onboarding, if: :user_signed_in?

  protected

  def after_sign_in_path_for(resource)
    if resource.needs_onboarding?
      onboarding_path
    else
      super
    end
  end

  def redirect_to_onboarding
    if current_user&.needs_onboarding? && !request.path.start_with?('/onboarding')
      redirect_to onboarding_path
    end
  end
end
