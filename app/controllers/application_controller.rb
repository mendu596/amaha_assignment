class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate

  private

  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      # Ensure environment variables are strings and not nil
      admin_user = ENV["ADMIN_USER"]&.to_s
      admin_password = ENV["ADMIN_PASSWORD"]&.to_s

      # Check if environment variables are set
      if admin_user.blank? || admin_password.blank?
        Rails.logger.error "ADMIN_USER or ADMIN_PASSWORD environment variables are not set"
        return false
      end

      ActiveSupport::SecurityUtils.secure_compare(username.to_s, admin_user) &
      ActiveSupport::SecurityUtils.secure_compare(password.to_s, admin_password)
    end
  end
end
