module GamePlayable
  extend ActiveSupport::Concern

  def game_params
    params.require(:game).permit(:winner, :score)
  end

  def sort_by_pool_diff(teams)
    teams.map do |court|
      court.sort! {|team1, team2| team2.pool_diff <=> team1.pool_diff}
    end
  end

  # takes in an array of Game instances
  # returns a hash with games divided by courts_ids (key = court_id, value = array of Games)
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

  # def get_teams_ids_from_court(games)
  #   games.map {|game| game["team_ids"]}.first.split("-").map do |team|
  #     team.split("/")
  #   end.flatten.map(&:to_i)
  # end

  # def sort_teams_by_record_points(group)
  #   group.sort_by do |team|
  #     team_wins, team_losses = team.pool_record.split("-").map(&:to_i)
  #     [team_wins, team.pool_diff]
  #   end.reverse
  # end

  # # returns an array of Team objects sorted by wins and pool_diff
  # def poolplay_standings(team_ids, teams)
  #   group = teams.select { |team| team_ids.include?(team.id) }
  #   sort_teams_by_record_points(group)
  # end

  def render_results(game)
    render(partial: 'shared/results_display', locals: {game: game})
  end

  def final_poolplay_standings(teams)
    sort_teams_by_record_points(teams)
  end
end
