module SessionsHelper
  def log_in(user)
    cookies.signed[:user_id] = user.id
  end

  def current_user
    @current_user ||= User.find_by(id: cookies.signed[:user_id])
    # elsif (user_id = cookies.signed[:user_id])
    #   user = User.find_by(id: user_id)
    #   if user && user.authenticated?(cookies[:remember_token])
    #     log_in user
    #     @current_user = user
    #   end
    # end
  end

  def user_logged_in?
    !!current_user
  end

  # def remember(user)
  #   user.remember
  #   cookies.permanent.signed[:user_id] = user.id
  #   cookies.permanent[:remember_token] = user.remember_token
  # end

  # def forget(user)
  #   user.forget
  #   cookies.delete(:user_id)
  #   cookies.delete(:remember_token)
  # end

  def log_out
    cookies.delete(:user_id)
    @current_user = nil
  end
end
