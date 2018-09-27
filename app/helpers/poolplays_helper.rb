module PoolplaysHelper
  def convert_team_ids_to_player_first_names_kob(team_ids)
    team1, team2 = team_ids.split("-")
    players = team_ids.split("-").map do |team|
      team.split('/').map do |player|
        Team.find(player.to_i).team_name.split(" ").first.capitalize
      end.join('/')
    end.join(" vs ")
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

  def find_differential(game)
    if game["score"].nil?
      return ''
    end
    game["score"].split("-").map(&:to_i).reduce(:-)
  end

  def find_loser(game)

  end
end
