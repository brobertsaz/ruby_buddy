class Api::BaseController < ApplicationController
  before_action :authenticate_user!
  protect_from_forgery with: :null_session

  respond_to :json

  # Handle authentication failures for API requests
  rescue_from ActionController::InvalidAuthenticityToken, with: :render_unauthorized

  private

  def render_json_success(message, data = {})
    render json: { success: true, message: message }.merge(data)
  end

  def render_json_error(message, status = :unprocessable_entity)
    render json: { success: false, error: message }, status: status
  end

  def render_unauthorized
    render_json_error("Unauthorized access", :unauthorized)
  end

  def render_forbidden
    render_json_error("Access forbidden", :forbidden)
  end

  # Override Devise's unauthenticated response for API
  def unauthenticated_api_response
    render_unauthorized
  end
end