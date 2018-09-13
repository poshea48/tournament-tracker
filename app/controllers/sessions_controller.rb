class SessionsController < ApplicationController
  def new
  end

  def create
    @user = User.find_by_email(params[:session][:email])
    if @user && @user.authenticate(params[:session][:password])
      log_in @user
      params[:session][:remember_me] == '1' ? remember(@user) : forget(@user)
      flash[:success] = "You have logged in successfully"
      redirect_to tournaments_path
    else
      flash[:danger] = "Email/password combination was incorrect"
      redirect_to login_path
    end
  end

  def destroy
    if user_logged_in?
      log_out
      flash[:info] = "You have logged out successfully"
    end
    redirect_to tournaments_path
  end
end
