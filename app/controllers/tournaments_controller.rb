class TournamentsController < ApplicationController
  include TournamentsHelper
  before_action :set_tournament, only: [:show, :edit, :add_team, :add_to_tournament, :update, :pool_play, :destroy]
  before_action :set_user
  before_action :restrict_access, only: [:new, :create, :edit, :join, :destroy]
  before_action :set_teams, only: [:show, :pool_play]

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

  def add_team
    unless @tournament.registration_open
      flash[:danger] = "Registration is closed"
      redirect_to tournament_path(@tournament)
    end

    if @tournament.tournament_type == 'kob'
      @player = User.new
    else
      @player1 = User.new
      @player2 = User.new
    end
  end

  def add_to_tournament
    @player = User.find_by_email(params[:email])
    if @player
      team = Team.create(user_id: @player.id, tournament_id: @tournament.id,
                        team_name: "#{@player.first_name}" )
      flash[:success] = "Player has been added"
      redirect_to tournament_path(@tournament)
    else
      flash[:danger] = "Player could not be found"
      redirect_to tournament_path(@tournament)
    end
  end

  def update
    if @tournament.poolplay_started && params[:poolplay][:registration_open]
      flash[:danger] = "Poolplay has already started can not open registration"
      redirect_to tournament_path(@tournament)
    end
    
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
      params.require(:tournament).permit(:name, :date, :tournament_type, :registration_open, :poolplay_started, :poolplay_finished, :closed)
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

    def set_teams
      @teams = @tournament.sort_teams_by_points
    end
end
