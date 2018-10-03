module PoolplaysHelper
  def create_game_title_from_team_ids(team_ids)
    players = team_ids.split("-").map do |team|
      team.split('/').map do |team_player|
        @tournament.teams.select {|player| player.id == team_player.to_i}.first.team_name.split(" ").first.capitalize
      end.join('/')
    end.join(" vs ")
  end

  def team_name_with_team_number_array(team_ids)
    team1_id, team2_id = team_ids.split("-")
    team1_name, team2_name = create_game_title_from_team_ids(team_ids).split(" vs ")
    [[team1_name, team1_id], [team2_name, team2_id]]
  end

  def get_names_of_team_kob(team_ids)
    player1, player2 = team_ids.split("/").map(&:to_i)

    @tournament.teams.select {|player| player.id == player1 || player.id == player2 }.map(&:team_name).join("/")
  end

  def divide_pool_by_courts(pool)
    courts = [[]]
    courts = {}
    pool.each do |game|
      if courts.key?(game["court_id"])
        courts[game["court_id"]].push(game)
      else
        courts[game["court_id"]] = [game]
      end
    end
    courts
  end

  def update_team_pool_differentials(game, playoffs)
    diff = find_differential(game["score"])
    winners = game["winner"]
    losers = find_losers(game)

    winners.split("/").each do |winner|
      team = Team.find(winner)

      if playoffs
        player_score = team.playoffs.to_i
        team.update!(playoffs: player_score + diff)
      else
        team.update!(pool_diff: team.pool_diff += diff)
      end
    end

    losers.split("/").each do |loser|
      team = Team.find(loser)

      if playoffs
        player_score = team.playoffs.to_i
        team.update!(playoffs: player_score - diff)
      else
        team.update!(pool_diff: team.pool_diff -= diff)
      end
    end
  end

  def find_differential(score)
    if score.nil?
      return 0
    end
    score.split("-").map(&:to_i).reduce(:-)
  end

  def find_losers(game)
    teams = game["team_ids"].split('-') # '5/6-3/4'['5/6', '3/4']
    teams.select { |team| team != game["winner"]}.first
  end

  def get_teams_ids_from_court(games)
    games.map {|game| game["team_ids"]}.first.split("-").map do |team|
      team.split("/")
    end.flatten.map(&:to_i)
  end

  def sort_by_pool_diff(playoff_teams)
    playoff_teams.map do |court|
      court.sort_by{|team| team.pool_diff}.reverse
    end
  end

  def update_users_points(teams, points)
    teams.each_with_index do |team, i|
      user = User.find(team.user_id)
      user.update!(points: user.points + points[i])
    end
  end

  def points_earned_kob(num_of_teams)
    points = [100, 50, 25, 20, 20]

    until points.length == num_of_teams
      points << 10
    end
    points
  end

  # input [[3,4,1,2], [6,7,8,9]]
  # def sort_by_pool_diff(teams)
  #   sorted = []
  #   teams.each do |court|
  #     sorted.push(court.map {|team| team.})
  # end
end
