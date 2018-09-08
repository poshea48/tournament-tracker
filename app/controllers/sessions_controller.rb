class SessionsController < ApplicationController
  def new
  end

  def create
    @user = User.find_by_email(params[:session][:email])
    if @user && @user.authenticate(params[:session][:password])
      session[:user_id] = @user.id
      flash[:success] = "You have signed in successfully"
      redirect_to tournaments_path
    else
      flash[:danger] = "Email/password combination was incorrect"
      redirect_to signin_path
    end
  end

  def destroy
    session[:user_id] = nil
    flash[:info] = "You have been signed out"
    redirect_to tournaments_path
  end
end
