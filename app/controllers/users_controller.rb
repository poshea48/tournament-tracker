class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit]

  def index
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save(user_params)
      flash[:success] = "You have signed up successfully"
      session[:user_id] = @user.id
      redirect_to tournaments_path
    else
      flash.now[:danger] = "You have not signed up successfully"
      render :new
    end
  end

  def show
  end

  def edit
  end

  private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :points, :admin)
    end
end
