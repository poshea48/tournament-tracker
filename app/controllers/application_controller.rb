class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_user, :user_signed_in?
  rescue_from ActiveRecord::RecordNotFound, with: :resource_not_found

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def user_signed_in?
    !!current_user
  end 

  protected
    def resource_not_found

    end
end
