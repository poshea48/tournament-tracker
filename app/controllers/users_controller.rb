class UsersController < ApplicationController
  # before_action :set_user, only: [:show, :edit, :index]
  before_action :make_read_only, except: [:index]

  def index
    @users = User.all.sort_by {|player| player.points}.reverse
    @user = current_user
  end

  def new
    @new_user = User.new
  end

  def create
    @admin = nil
    if current_user && current_user.admin
      @admin = current_user
    end

    @new_user = User.new(user_params)
    if @new_user.save
      if @admin
        redirect_to players_path
      else
        log_in @new_user
        flash[:success] = "You have signed up successfully"
        redirect_to tournaments_path
      end
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
