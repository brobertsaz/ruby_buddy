class SettingsController < ApplicationController
  before_action :authenticate_user!

  def index
    # Main settings page
  end

  def update_role
    if current_user.update(role: params[:user][:role])
      redirect_to settings_path, notice: "Role updated successfully!"
    else
      redirect_to settings_path, alert: "Failed to update role."
    end
  end

  def update_email
    if current_user.update(email: params[:user][:email])
      redirect_to settings_path, notice: "Email updated successfully!"
    else
      redirect_to settings_path, alert: "Failed to update email: #{current_user.errors.full_messages.join(', ')}"
    end
  end

  def update_password
    if params[:user][:password].blank?
      redirect_to settings_path, alert: "Password cannot be blank."
      return
    end

    if current_user.update_with_password(
      current_password: params[:user][:current_password],
      password: params[:user][:password],
      password_confirmation: params[:user][:password_confirmation]
    )
      bypass_sign_in(current_user) # Sign in the user again to avoid logout
      redirect_to settings_path, notice: "Password updated successfully!"
    else
      redirect_to settings_path, alert: "Failed to update password: #{current_user.errors.full_messages.join(', ')}"
    end
  end
end

