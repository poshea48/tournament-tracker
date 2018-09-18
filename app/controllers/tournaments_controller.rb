class TournamentsController < ApplicationController
  before_action :set_tournament, only: [:show, :edit, :update, :destroy]
  before_action :set_user
  before_action :restrict_access, only: [:new, :create, :edit, :destroy]

  def index
    @tournaments = Tournament.all
  end

  def new

    @tournament = Tournament.new
  end

  def create
    @tournament = Tournament.new(tournament_params)
    if @tournament.save
      flash[:success] = "Tournament has been created"
      redirect_to tournaments_path
    else
      flash.now[:danger] = "Tournament has not been created"
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    @tournament.update(tournament_params)
    if @tournament.save
      flash[:success] = "Tournament has been updated"
      redirect_to tournament_path(@tournament)
    else
      flash[:danger] = "Tournament has not been updated"
      render :edit
    end
  end

  def destroy
    if @tournament.closed && @tournament.destroy
      flash[:info] = "Tournament has been deleted"
      redirect_to tournaments_path
    else
      flash[:danger] = "Tournament has not been deleted.  It must be closed first"
      redirect_to tournaments_path
    end
  end

  protected
  def resource_not_found
    flash[:danger] = "The tournament you are looking for could not be found"
    redirect_to root_path
  end

  private

    def set_tournament
      @tournament = Tournament.find(params[:id])
    end

    def tournament_params
      params.require(:tournament).permit(:name, :date, :tournament_type, :registration_open, :closed)
    end

    def set_user
      @user = current_user
    end

    def restrict_access
      unless @user && @user.admin?
        flash[:danger] = "You do not have access to that page"
        redirect_to root_path
      end
    end
end
