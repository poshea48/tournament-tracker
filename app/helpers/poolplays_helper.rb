module PoolplaysHelper
  def find_differential(score)
    if score.nil?
      return 0
    end
    score.split("-").map(&:to_i).reduce(:-)
  end

  def find_losers(game)
    teams = game.team_ids.split('-') # '5/6-3/4'['5/6', '3/4']
    teams.select { |team| team != game.winner}.first
  end

  def create_game_title_from_team_ids(team_ids)
    players = team_ids.split("-").map do |team|
      team.split('/').map do |team_player|
        @tournament.teams.select {|player| player.id == team_player.to_i}.first.team_name.split(" ").first.capitalize
      end.join('/')
    end.join(" vs ")
  end

  # given 2 teams, creates an array with 2 arrays of team names and team ids [["Paul/Abigail", "21/23"], ["Mac/Nani", "24/25"]]
  def team_name_with_team_number_array(team_ids)
    team1_id, team2_id = team_ids.split("-")
    team1_name, team2_name = create_game_title_from_team_ids(team_ids).split(" vs ")
    [[team1_name, team1_id], [team2_name, team2_id]]
  end

  def get_names_of_team_kob(team_ids)
    player1, player2 = team_ids.split("/").map(&:to_i)

    @tournament.teams.select {|player| player.id == player1 || player.id == player2 }.map(&:team_name).join("/")
  end

  def points_earned_kob(num_of_teams)
    if num_of_teams == 4
      return [100, 50, 25, 20]
    else
      points = [100, 50, 25, 20, 20]

      until points.length == num_of_teams
        points << 10
      end
      return points
    end
  end

  def get_court_standings(court_id, stage, tournament)
    pool = nil
    if stage == 'poolplay'
      pool = tournament.poolplays.select { |pool| pool.court_id == court_id}
    else
      pool = tournament.playoffs.select { |pool| pool.court_id == court_id }
    end
    team_ids = get_teams_ids_from_court(pool)
    poolplay_standings(team_ids, tournament.teams)
  end

  def get_teams_ids_from_court(games)
    games.map {|game| game["team_ids"]}.first.split("-").map do |team|
      team.split("/")
    end.flatten.map(&:to_i)
  end

  def sort_teams_by_record_points(group)
    group.sort_by do |team|
      team_wins, team_losses = team.pool_record.split("-").map(&:to_i)
      [team_wins, team.pool_diff]
    end.reverse
  end

  # returns an array of Team objects sorted by wins and pool_diff
  def poolplay_standings(team_ids, teams)
    group = teams.select { |team| team_ids.include?(team.id) }
    sort_teams_by_record_points(group)
  end

  # input [[3,4,1,2], [6,7,8,9]]
  # def sort_by_pool_diff(teams)
  #   sorted = []
  #   teams.each do |court|
  #     sorted.push(court.map {|team| team.})
  # end
end
