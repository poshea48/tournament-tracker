class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  # helper_method :current_user, :user_signed_in?
  rescue_from ActiveRecord::RecordNotFound, with: :resource_not_found

  include SessionsHelper

  protected
    def resource_not_found

    end
end
