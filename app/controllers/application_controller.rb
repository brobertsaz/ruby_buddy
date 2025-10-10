class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # Temporarily disabled to allow all browsers during development
  # allow_browser versions: :modern

  before_action :redirect_to_onboarding, if: :user_signed_in?

  protected

  def after_sign_in_path_for(resource)
    return onboarding_path if resource.needs_onboarding?

    # Everyone goes to dashboard after sign in
    dashboard_path
  end

  def redirect_to_onboarding
    return unless current_user&.needs_onboarding?

    # Allow onboarding flow pages, first-setup destinations, and sign-out
    allowed_prefixes = [
      "/onboarding",
      "/profiles/new",              # mentor setup
      "/mentorship_requests/new",   # mentee setup
      "/users/sign_out"             # allow sign-out
    ]

    return if allowed_prefixes.any? { |p| request.path.start_with?(p) }

    redirect_to onboarding_path
  end
end
