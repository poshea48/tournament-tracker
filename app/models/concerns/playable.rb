module Playable
  extend ActiveSupport::Concern


  # def update_kob_player_diff_playoffs(team, diff, winner)
  #   if winner
  #     team.split("/").each do |winner|
  #       team = Team.find(winner)
  #
  #   else
  #     update_kob_record_playoffs(winners, losers, diff)
  #
  #   else
  #
  #
  #
  #
  #     if playoffs && (tourn_type == 'team' || tourn_type == 'kob/team')
  #       update_team_play_playoffs(team)
  #
  #     else
  #     end
  #   end
  #
  #   losers.split("/").each do |loser|
  #     team = Team.find(loser)
  #
  #     if playoffs
  #       player_score = team.playoffs.to_i
  #       team.update!(playoffs: player_score - diff)
  #     else
  #       team.update!(pool_diff: team.pool_diff -= diff)
  #     end
  #   end
  # end
  #
  # def update_team_play_playoffs(team)
  #
  # end





  def save_team_play_to_database(pool, tourn_id, playoffs)
    if pool.nil?
      return false
    end
    # {1:[1, 5], 2:[2, 6], 3:[3, 7], 4:[4,8]}
    # Add player2_id to each team
    pool.keys.each do |team|
      first, second = team.map {|player| Team.find(player)}
      Team.update(first.id, player2_id: second.id, playoffs: "#{team}-5")
      Team.update(second.id, player2_id: first.id, playoffs: "#{team}-5")
    end
    #bracket = {1: [[1/5, 4/8], [2/6, 3/7]]}
    seeds = pool.keys
    if pool.keys.size % 4 == 0 && pool.keys.size >= 4
      until seeds.empty?
        high_seed = pool[seeds.shift]
        low_seed = pool[seeds.pop]
      end
    end
  end

  def save_kob_to_database(pool, tourn_id, playoffs)
    if pool.nil?
      return false
    end
    # result = []
    pool.keys.each do |court|
      teams = randomly_generate_kob_teams(pool[court])
      games = generate_kob_games(teams)
      games.each do |game|
        if playoffs
          Game.create(tournament_id: tourn_id, team_ids: game,
                        round: cour)
        # else
        #   result << Poolplay.create(tournament_id: tourn_id, team_ids: game,
        #                 court_id: court, version: version)
        end
      end
    end
    # result.empty? ? false : result
  end

  def self.randomly_assign_kob_players_to_courts(teams)
    court = 1
    result = {court => []}
    until teams.empty?
      team = teams.slice!(rand(teams.length))
      if result[court].length == 4
        # result[court] = randomly_generate_kob_teams(result[court])
        court += 1
        result[court] = [team]
      else
        result[court].push(team)
      end
    end
    result
  end



  # add games to database
  def self.add_games_to_database(court, games, tourn_id)
    games.each do |game|
      Poolplay.create(tournament_id: tourn_id, team_ids: games,
                      court_id: court)
    end
  end

  # randomly create 3 games from a group of 4 teams
  # group = [1, 2, 3, 4]
  # return value = [[1, 2], [1, 3], [1, 4], [2, 3], [2, 4], [3, 4]]
  # each sub array is a team of 2 kob players


  def save_kob_to_database(pool, tourn_id)
    if pool.nil?
      return false
    end
    result = []
    pool.keys.each do |court|
      teams = randomly_generate_kob_teams(pool[court])
      games = generate_kob_games(teams)
      games.each do |game|
        if
          result << Poolplay.create(tournament_id: tourn_id, team_ids: game,
                          court_id: court, version: version)
        else
          result << Poolplay.create(tournament_id: tourn_id, team_ids: game,
                        court_id: court, version: version)
        end
      end
    end
    result.empty? ? false : result
  end

end
