class ApplicationController < ActionController::Base

  protect_from_forgery with: :exception
  # helper_method :current_user, :user_signed_in?
  rescue_from ActiveRecord::RecordNotFound, with: :resource_not_found

  include SessionsHelper

  protected
    def resource_not_found

    end

    def make_read_only
      unless current_user && current_user.admin?
        flash[:danger] = "You are in read-only mode, cannot perform that action"
        redirect_to root_path
      end
    end
end
