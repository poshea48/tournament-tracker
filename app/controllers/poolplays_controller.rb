class PoolplaysController < ApplicationController
  include PoolplaysHelper
  include TournamentsHelper
  include GamePlayable

  # creats @tournament
  before_action :set_tournament

  # creates @poolplay
  before_action :set_poolplay, except: [:new, :create, :create_temporary_pool, :final_results, :leaderboard]

  # if still in poolplay sets Tournament poolplay_finished to true stays in poolplay_path
  before_action :start_playoffs

  # restricts starting a new poolplay
  before_action :start_pool_play_access, only: [:new, :create_temporary_pool, :create]

  #restricts access if Tournament is set to registration_open == false or
  #there are no teams entered or team number is not divisiible by 4
  before_action :restrict_access

  before_action :validate_team_numbers, only: [:new, :create]

  def index
    @current_user = current_user
    @game = 'poolplay'
  end

  def new
    if @tournament.poolplay_started
      redirect_to poolplay_path(@tournament.id)
    end
    @temp_pool = session[:temp_pool]
  end

  def create_temporary_pool
    type = @tournament.tournament_type
    if type == 'kob' || 'kob/team'
      @temp_pool_now = Game.create_random_kob_poolplay(@tournament)
      #{1: [3, 4, 8, 5], 2: [1, 2, 7, 6]}
    else
      @temp_pool_now = Game.create_random_team_poolplay(@tournament)
    end
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

  #params["pool"] = {1: [3, 4, 8, 5], 2: [1, 2, 7, 6]}
  def create
    kob = @tournament.tournament_type == 'kob' || @tournament.tournament_type == 'kob/team'
    pool = nil

    if session[:temp_pool]
      if kob
        pool = Game.save_kob_to_database(@tournament.id, params["pool"], "poolplay")
      else
        pool = Game.save_team_play_to_database(@tournament.id, params["pool"], "poolplay")
      end
    else
      if kob
        pool = Game.create_seeded_kob_poolplay(@tournament)
      else
        pool = Game.create_seeded_teams_poolplay(@tournament)
      end
    end

    if pool
      Tournament.update(@tournament.id, poolplay_started: true)
      flash[:success] = "Pool play has started"
      session[:temp_pool] = nil
      redirect_to poolplay_path(@tournament)
    else
      flash[:danger] = "Something went wrong"
      redirect_to tournament_path(@tournament)
    end
  end

  def edit
    game_id = params[:pool_id].to_i #|| params[:playoff_id]
    @game = @tournament.poolplays.select {|game| game.id == game_id}.first
    @team_1, @team_2 = team_name_with_team_number_array(@game.team_ids)

    respond_to do |format|
      format.html
      format.js
    end
  end

  def update
    game_id = params[:game_id].to_i
    game = Game.find(game_id)

    if params[:game][:winner].nil?
      flash[:danger] = "You need to select a winner"
    elsif params[:game][:score].empty? || params[:game][:score].nil? || params[:game][:score].match(/\A[2]\d+-\d{1,2}\z/).nil?
      flash[:danger] = "Score entered incorrectly"
    else
      game.update(game_params)
      if game.save
        # move out of Playable and into model(out of class method)
        game.update_play(@tournament.tournament_type, false)
        ActionCable.server.broadcast 'results_channel',
                                      game: render_results(game),
                                      game_id: game.id,
                                      playoffs: false
      else
        flash[:danger] = "Score was not entered"
      end
    end

    redirect_to poolplay_path(@tournament)
  end

  def leaderboard
    @in_playoffs = false
    @kob = @tournament.tournament_type == 'kob' || @tournament.tournament_type == 'kob/team'
    @court = params["court_id"].to_i
    @teams = get_court_standings(@court, 'poolplay', @tournament)

    respond_to do |format|
      format.js
      format.html { redirect_to poolplay_path(@tournament)}
    end
  end

  def poolplay_finished
    if @poolplay && @poolplay.none? {|game| game["score"].nil? } && !@tournament.poolplay_finished
      Tournament.update(@tournament.id, poolplay_finished: true)
    # else
    #   render :index
    end
    redirect_to(poolplay_path(@tournament))
  end

  private
    def set_tournament
      @tournament = Tournament.find(params[:id])
    end

    def start_pool_play_access
      if @tournament.poolplay_started
        flash[:danger] = "You can not access this page, pool play has already started"
        redirect_to poolplay_path(@tournament)
      end
    end

    def set_poolplay
      @poolplay = @tournament.poolplays
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

    def start_playoffs # all
      if @poolplay.nil?
        return
      end
      if @poolplay.none? {|game| game["score"].nil? } && !@tournament.poolplay_finished
        Tournament.update(@tournament.id, poolplay_finished: true)
        redirect_to(poolplay_path(@tournament))
      end
    end
end
