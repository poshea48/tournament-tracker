class PlayoffsController < ApplicationController
  include PoolplaysHelper
  include GamePlayable

  before_action :set_tournament
  before_action :check_access

  before_action :set_playoffs, only: [:index, :edit, :playoffs_finished]
  before_action :end_tournament

  def index
  end

  def create
    if @tournament.playoffs_started
      return redirect_to playoffs_path(@tournament)
    end

    kob = @tournament.tournament_type == 'kob'
    courts = divide_pool_by_courts(@tournament.poolplays)

    playoff_teams = courts.keys.map do |court|
      team_ids = get_teams_ids_from_court(courts[court])
      poolplay_standings(team_ids, @tournament.teams).map {|team| team.id}
    end
    binding.pry

     #[[3,4,1,2], [6,7,8,9]]creates an array of array of Teams based on what court they played on
     # and sorted by record then diff
      # passes Teams array to class method create_playoffs
      # creates playoff with kob set to true or false, true for kob playoffs, false for team playoffs
    pool = nil
    if kob
      pool = Game.create_kob_playoffs(@tournament.id, playoff_teams)
    else
      pool = Game.create_team_play_playoffs(@tournament.id, playoff_teams)
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
    game_id = params[:playoff_id]
    @game = @tournament.get_pool(game_id.to_i)
    @team_1, @team_2 = team_name_with_team_number_array(@game.team_ids)

    respond_to do |format|
      format.html
      format.js
    end
  end

  def update
    game_id = params[:game_id]
    game = Game.find(game_id)

    if params[:playoff][:winner].nil?
      flash[:danger] = "You need to select a winner"
    elsif params[:playoff][:score].empty? || params[:playoff][:score].nil? || params[:playoff][:score].match(/\A[2]\d+-\d{1,2}\z/).nil?
      flash[:danger] = "Score entered incorrectly"
    else
      game.update(playoff_params)
      if game.save
        update_team_pool_differentials(game, playoffs_started)
        ActionCable.server.broadcast 'results_channel',
                                      game: render_results(game),
                                      game_id: game.id,
                                      playoffs: true
      else
        flash[:danger] = "Score was not entered"
      end
    end

    redirect_to playoff_path(@tournament)
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
  end

  def check_access
    unless @tournament.poolplay_finished
      flash[:danger] = "Pool play must be finished to access this page"
      redirect_to poolplay_path(@tournament)
    end
  end

  def playoff_params
    params.require(:playoff).permit(:winner, :score)
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
