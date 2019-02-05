class PlayoffsController < ApplicationController
  include PoolplaysHelper
  include GamePlayable

  before_action :set_tournament
  before_action :check_access

  before_action :set_playoffs, only: [:index, :edit, :playoffs_finished]
  before_action :end_tournament

  def index
    @game = 'playoffs'
  end

  def create
    if @tournament.playoffs_started
      return redirect_to playoffs_path(@tournament)
    end

    kob = @tournament.tournament_type == 'kob'

    courts = divide_pool_by_courts(@tournament.poolplays)

    # sort poolplay
    playoff_teams = courts.keys.map do |court|
      team_ids = get_teams_ids_from_court(courts[court])
      poolplay_standings(team_ids, @tournament.teams).map {|team| team.id}
    end

     #[[3,4,1,2], [6,7,8,9]]creates an array of array of Teams based on what court they played on
     # and sorted by record then diff
      # passes Teams array to class method create_playoffs
      # creates playoff with kob set to true or false, true for kob playoffs, false for team playoffs
    pool = nil
    if kob
      pool = Game.create_kob_playoffs(@tournament)
    else
      pool = Game.create_teams_playoffs(@tournament.id, playoff_teams)
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
    @game = @tournament.playoffs.select {|game| game.id == game_id}.first
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
    pool = @tournament.playoffs.select { |pool| pool.court_id == @court }
    team_ids = get_teams_ids_from_court(pool)
    # function from private
    @teams = playoff_kob_standings(team_ids, @tournament.teams)
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
    if @tournament.poolplays.select { |pool| pool.court_id >= 100 }.none? {|pool| pool.score.nil?}
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
    if @tournament.playoffs_started
      @playoffs = @tournament.playoffs
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
    if !@tournament.closed && @tournament.playoffs_started && @tournament.games.none? {|pool| pool.score.nil?}
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
