class SessionsController < ApplicationController
  def new
  end

  def create
    @user = User.find_by_email(params[:session][:email])
    if @user && @user.authenticate(params[:session][:password])
      log_in @user
      flash[:success] = "You have logged in successfully"
      redirect_to tournaments_path
    else
      flash[:danger] = "Email/password combination was incorrect"
      redirect_to login_path
    end
  end

  def destroy
    log_out 
    flash[:info] = "You have logged out successfully"
    redirect_to tournaments_path
  end
end
