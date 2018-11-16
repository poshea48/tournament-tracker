class PoolplaysController < ApplicationController
  include PoolplaysHelper
  include TournamentsHelper
  include GamePlayable

  before_action :set_tournament
  before_action :set_poolplay, except: [:new, :create, :create_temporary_pool, :final_results, :leaderboard]
  before_action :start_playoffs
  before_action :start_pool_play_access, only: [:new, :create_temporary_pool, :create]
  before_action :restrict_access
  before_action :validate_team_numbers, only: [:new, :create]

  def index
    @current_user = current_user
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
      if game.update(game_params)
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
    @court = params["court_id"].to_i
    # @in_playoffs = @court >= 100
    pool = @tournament.poolplays.select { |pool| pool.court_id == @court }

    team_ids = get_teams_ids_from_court(pool)

    @teams = poolplay_standings(team_ids, @tournament.teams)
    @in_playoffs = false

    # @teams = @tournament.teams.select { |team| team_ids.include?(team.id) }
    #   .sort do |team1, team2|
    #   if @court == 100 || @court == 101
    #     team2.playoffs.to_i <=> team1.playoffs.to_i
    #   else
    #     team2.pool_diff <=> team1.pool_diff
    #   end
    # end

    respond_to do |format|
      format.html
      format.js
      format.json { render json: @teams }
    end
  end

  #takes in an array of Team ids for a court
  #returns an array of Team objects sorted by record and point diff
  #used for leaderboard and creating playoff



  # similar to poolplay standings but uses the team playoffs attribute


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

    # def game_params
    #   params.require(:game).permit(:winner, :score)
    # end

    def render_results(game)
      render(partial: 'shared/results_display', locals: {game: game})
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
