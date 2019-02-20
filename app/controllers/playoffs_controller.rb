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
    # @game = @tournament.get_pool(game_id.to_i)
    # @team_1, @team_2 = team_name_with_team_number_array(@game.team_ids)
    # # @path =

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
    @points = points_earned_kob(@winners.length)
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @winners }
    end
  end

  def playoffs_finished
    if @tournament.playoff_games.none? {|pool| pool.score.nil?}
      Tournament.update(@tournament.id, closed: true)
      teams = @tournament.final_results_list
      update_users_points(teams, points_earned_kob(teams.length))
    # else
    #   render :playoffs
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

  def playoff_kob_standings(team_ids, teams)
    teams.select { |team| team_ids.include?(team.id) }
      .sort_by do |team|
        team_wins, diff = team.playoffs.split("-").map(&:to_i)
        [team_wins, team.pool_diff]
      end.reverse
  end

  def end_tournament
    if !@tournament.closed && @tournament.playoff_games.none? {|pool| pool.score.nil?}
      Tournament.update(@tournament.id, closed: true)
      teams = @tournament.final_results_list #
      update_users_points(teams, points_earned_kob(teams.length))
      redirect_to playoffs_path(@tournament)
    end
  end

  def update_users_points(teams, points)
    teams.each_with_index do |team, i|
      user = team.user
      user.update!(points: user.points + points[i])
    end
  end
end
