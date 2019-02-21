class PlayoffsController < ApplicationController
  include PoolplaysHelper
  include GamePlayable

  before_action :set_tournament
  before_action :check_access
  before_action :set_user

  before_action :set_playoffs, only: [:index, :edit, :playoffs_finished]
  before_action :end_tournament, except: [:create]

  def index
    @game = 'playoffs'
  end

  def create
    # fix @tournament.playoff_games
    if !@tournament.playoff_games.empty?
      return redirect_to playoffs_path(@tournament)
    end
    kob = @tournament.tournament_type == 'kob'
    pool = nil

    if kob
      pool = @tournament.create_kob_playoffs
    else
      pool = @tournament.create_teams_from_kob_playoffs
    end

    if pool
      Tournament.update(@tournament.id, playoffs_started: true)
      redirect_to playoffs_path(@tournament)
    else
      flash[:danger] = "Something went wrong"
      redirect_to poolplay_path(@tournament)
    end
  end

  def edit
    game_id = params[:pool_id].to_i
    @game = @tournament.playoff_games.select {|game| game.id == game_id}.first
    @team_1, @team_2 = team_name_with_team_number_array(@game.team_ids)

    respond_to do |format|
      format.html
      format.js
    end
  end

  def update
    game_id = params[:game_id]
    game = Game.find(game_id)

    if params[:game][:winner].nil?
      flash[:danger] = "You need to select a winner"
    elsif params[:game][:score].empty? || params[:game][:score].nil? || params[:game][:score].match(/\A[2]\d+-\d{1,2}\z/).nil?
      flash[:danger] = "Score entered incorrectly"
    else
      game.update(playoff_params)
      if game.save
        game.update_play(@tournament.tournament_type, true)
        ActionCable.server.broadcast 'results_channel',
                                      game: render_results(game),
                                      game_id: game.id,
                                      playoffs: true
      else
        flash[:danger] = "Score was not entered"
      end
    end

    redirect_to playoffs_path(@tournament)
  end

  # only used if playoff style is kob
  def leaderboard
    @court = params["court_id"].to_i
    @in_playoffs = true
    @teams = @tournament.get_court_standings(@court, @in_playoffs)
  end

  def final_results
    @winners = @tournament.final_results_list
    @points = @tournament.points_earned_kob
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @winners }
    end
  end

  def playoffs_finished
    if @tournament.playoff_games.none? {|pool| pool.score.nil?}
      end_tournament
    end
    redirect_to playoffs_path(@tournament)
  end

  private

  def set_tournament
    @tournament = Tournament.find(params[:id])
  end

  def set_user
    @user = current_user
  end

  def check_access
    unless @tournament.poolplay_finished
      flash[:danger] = "Pool play must be finished to access this page"
      redirect_to poolplay_path(@tournament)
    end
  end

  def playoff_params
    params.require(:game).permit(:winner, :score)
  end

  def set_playoffs # only: [:playoffs, :leaderboard, :edit]
    if !@tournament.playoff_games.empty?
      @playoffs = @tournament.playoff_games
      @playoff_courts = divide_pool_by_courts(@playoffs)
    end
  end

  def end_tournament
    if !@tournament.closed && @tournament.playoff_games.none? {|pool| pool.score.nil?}
      @tournament.end
      redirect_to playoffs_path(@tournament)
    end
  end
end
