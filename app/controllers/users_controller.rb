class UsersController < ApplicationController
  before_action :set_user#, only: [:show, :edit, :index, :edit_password, :update_password]
  before_action :make_read_only, only: [:new]

  def index
    @users = User.all.sort_by {|player| player.points}.reverse
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
    @player = User.find_by_id(params[:id])
    players = User.all.sort_by {|player| player.points}.reverse
    @ranking = players.index(@player) + 1
    @tournaments = @player.tournaments_played
  end

  def edit
    restrict_access(params[:id].to_i)
  end

  def update
    restrict_access(params[:id].to_i)
  end

  def edit_password
    restrict_access(params[:id].to_i)

    @user = current_user

  end

  def update_password
    @user = current_user

    @user.update(user_params)

    if @user.save
      flash[:success] = "You have changed your password"
      redirect_to player_path(@user)
    else
      flash.now[:danger] = "Password not changed"
      render 'edit_password'
    end
  end

  private

    def set_user
      @user = current_user
    end

    def restrict_access(profile_id)
      if @user.nil? || @user.id != profile_id
        flash[:danger] = "You do not have access to that page"
        redirect_to root_path
      end
    end

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :points, :admin)
    end
end
