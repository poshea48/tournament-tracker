class SessionsController < ApplicationController

  def new
    @user = User.new
  end

  def create
    @user = User.find_by_email(params[:session][:email].downcase)
    if @user && @user.authenticate(params[:session][:password])
      log_in @user
      remember @user
      flash[:success] = "You have logged in successfully"
      redirect_to tournaments_path
    else
      flash[:danger] = "Invalid Email/password combination"
      render 'new'
    end
  end

  def destroy
    if user_logged_in?
      log_out
      flash[:info] = "You have logged out successfully"
    end
    redirect_to tournaments_path
  end

  private

end
