class PoolplaysController < ApplicationController
  include PoolplaysHelper
  include TournamentsHelper

  before_action :set_tournament
  before_action :start_pool_play_access, only: [:new, :create_temporary_pool, :create]

  before_action :set_poolplay, except: [:new, :create, :create_temporary_pool, :final_results]
  before_action :restrict_access
  before_action :validate_team_numbers, only: [:new, :create]
  before_action :start_playoffs, except: [:final_results]
  # before_action :set_poolplay, only: [:index]
  before_action :set_playoffs, only: [:playoffs, :leaderboard, :edit]
  before_action :end_tournament


  def index
  end

  def new
    if @tournament.poolplay_started
      redirect_to poolplay_path(@tournament.id)
    end
    # @temp_pool = session[:temp_pool]
  end

  def create_temporary_pool
    @temp_pool_now = Poolplay.create_kob_pool(@tournament)
    session[:temp_pool] = nil
    session[:temp_pool] = @temp_pool_now
    @temp_pool_now
    respond_to do |format|
      # format.js {render layout: false}
      # binding.pry
      format.html { redirect_to new_poolplay_path @tournament.id }
      format.js {}
      format.json { render json: @temp_pool_now}
    end
    # redirect_to new_poolplay_path(@tournament)
  end

  def create

    if poolplay = Poolplay.save_kob_to_database(params["pool"], @tournament.id)
      flash[:success] = "Pool play has started"
      Tournament.update(@tournament.id, poolplay_started: true)
      redirect_to poolplay_path(@tournament)
    else
      flash[:danger] = "Something went wrong"
      redirect_to new_poolplay_path(@tournament)
    end
  end

  def edit
    game_id = params[:pool_id] || params[:playoff_id]
    @game = Poolplay.find(game_id)
    @team_1, @team_2 = team_name_with_team_number_array(@game.team_ids)

    respond_to do |format|
      format.html
      format.js
    end
  end

  def update
    game_id = params[:game_id]
    game = Poolplay.find(params[:game_id])
    playoffs_started = @tournament.playoffs_started

    if params[:poolplay][:score].empty? || params[:poolplay][:score].nil? || params[:poolplay][:score].match(/\A[2]\d+-\d{1,2}\z/).nil?
      flash[:danger] = "Score entered incorrectly"
      if @tournament.playoffs_started
        redirect_to playoffs_path(@tournament)
      else
        redirect_to poolplay_path(@tournament)
      end
    else
      game.update(poolplay_params)
      if game.save
        update_team_pool_differentials(game, playoffs_started)
        flash[:success] = "Results computed"
      else
        flash[:danger] = "Score was not entered correctly, must be in format xx-xx"
      end

      if @tournament.playoffs_started
        redirect_to playoffs_path(@tournament)
      else
        redirect_to poolplay_path(@tournament)
      end
    end
  end

  def leaderboard
    @court = params["court_id"].to_i
    courts = {}
    @playoffs = nil
    if @court == 100 || @court == 101
      courts = @playoff_courts
      @playoffs = true
    else
      courts = @courts
      @playoffs = false
    end
    team_ids = get_teams_ids_from_court(courts[@court])
    if @playoffs
      @teams = @tournament.teams.select do |team|
        team_ids.include?(team.id)
      end.sort_by { |team| team.playoffs.to_i }.reverse
    else
      @teams = @tournament.teams.select do |team|
        team_ids.include?(team.id)
      end.sort_by { |team| team.pool_diff }.reverse
    end
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @teams }
    end
  end

  def playoffs
    unless @tournament.playoffs_started
      flash[:danger] = "You can not access that page"
      redirect_to poolplay_path(@tournament)
    end
  end

  def create_playoff_pool
    if @tournament.poolplay_finished
      #[[3,4,1,2], [6,7,8,9]]
      playoff_teams = @courts.keys.map do |court|
        team_ids = get_teams_ids_from_court(@courts[court])
        @tournament.teams.select do |team|
          team_ids.include?(team.id)
        end
      end # creates a hash of Teams based on what court they played on
      # passes Teams hash to class method create_playoffs
      if Poolplay.create_playoffs(@tournament.id, sort_by_pool_diff(playoff_teams))
        Tournament.update(@tournament.id, playoffs_started: true)
      else
        flash[:danger] = "Something went wrong"
        redirect_to pool_path(@tournament)
      end
    end
    redirect_to playoffs_path(@tournament)
      # playoffs = Poolplay.create_playoffs(@tournament, sort_by_pool_diff(teams))
  end

  def final_results
    @winners = @tournament.final_results_list
    @points = points_earned_kob(@winners.length)
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @winners }
    end
  end

  private
    def set_tournament
      @tournament = Tournament.find(params[:id])
      # if session[:tournament].nil? || session[:tournament][params[:id]].nil?
      #   @tournament = Tournament.find(params[:id])
      #   session[:tournament] = {}
      #   session[:tournament][@tournament.id] = @tournament
      # else
      #   @tournament = session[:tournament][params[:id]]
      #   binding.pry
      # end
    end

    def start_pool_play_access
      if @tournament.poolplay_started
        flash[:danger] = "You can not access this page, pool play has already started"
        redirect_to poolplay_path(@tournament)
      end
    end

    def set_poolplay
      @poolplay = Poolplay.where(["tournament_id = ? and version = ?", "#{@tournament.id}", "pool"])
      if @poolplay.empty?
        redirect_to new_poolplay_path(@tournament.id)
      end
      @courts = divide_pool_by_courts(@poolplay)
    end

    def restrict_access
      if @tournament.registration_open || @tournament.teams.length == 0 || @tournament.teams.length % 4 != 0
        flash[:danger] = "You can not enter pool play"
        redirect_to tournament_path(@tournament)
      end
    end

    def validate_team_numbers
      if @tournament.teams.length % 4 != 0
        flash[:danger] = "You do not have the right amount of teams.  Must be multiples of 4"
        redirect_to tournament_path(@tournament)
      end
    end

    def poolplay_params
      params.require(:poolplay).permit(:winner, :score)
    end

    def start_playoffs # all
      if @poolplay.nil?
        return
      end
      if @poolplay.none? {|game| game["score"].nil? } && !@tournament.poolplay_finished
        Tournament.update(@tournament.id, poolplay_finished: true)
        redirect_to(poolplay_path(@tournament))
      end
    end

    def set_playoffs # only: [:playoffs, :leaderboard, :edit]
      if @tournament.playoffs_started
        @playoffs = Poolplay.where(["tournament_id = ? and version = ?", "#{@tournament.id}", "playoff"])
        @playoff_courts = divide_pool_by_courts(@playoffs)
      end
    end

    def end_tournament
      if !@tournament.closed && @tournament.playoffs_started && @tournament.poolplays.none? {|pool| pool.score.nil?}
        Tournament.update(@tournament.id, closed: true)
        binding.pry
        teams = @tournament.final_results_list
        update_users_points(teams, points_earned_kob(teams.length))
        redirect_to playoffs_path(@tournament)
      end
    end


end
