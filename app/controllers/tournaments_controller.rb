class TournamentsController < ApplicationController
  include TournamentsHelper
  include PoolplaysHelper

  before_action :set_tournament, except: [:index, :new, :create]#only: [:show, :edit, :add_team, :add_to_tournament, :update, :pool_play, :destroy]
  before_action :set_user
  before_action :restrict_access, only: [:new, :create, :edit, :join, :destroy]
  # before_action :set_teams, only: [:show, :pool_play]

  def landing
    
  end
  def index
    # @tournaments = Tournament.all
    @tournaments = Tournament.all.order("date DESC")
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

  # shows add_team form for user or admin
  def add_team
    @players = User.available_users(@tournament.id)
    unless @tournament.registration_open
      flash[:danger] = "Registration is closed"
      redirect_to tournament_path(@tournament)
    end
  end


  def add_to_tournament
    if @tournament.tournament_type == 'kob' || @tournament.tournament_type == 'kob/team'
      if params[:players] # adding mulitple players (only admin)
        params[:players].each do |player|
          player_id, player_name = player.split("-")
          @tournament.save_kob_team_to_database(player_id, player_name, 0, false)
        end
        flash[:success] = "#{'Player'.pluralize(params[:players].length)} added"
        redirect_to tournament_path(@tournament)
      else
        @players = User.available_users(@tournament.id)
        flash[:danger] = "You didnt add any players"
        render :add_team
      end
    else
      flash[:danger] = "Not ready for that functionality yet"
      redirect_to tournament_path(@tournament)
    end
  end

  def update
    if @tournament.poolplay_started && params[:poolplay] && params[:poolplay][:registration_open]
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

  def delete_team
    Team.find(params[:team_id]).destroy
    flash[:info] = "Team has been removed"
    redirect_to tournament_path(@tournament)
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

  def resource_not_found(error)
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
