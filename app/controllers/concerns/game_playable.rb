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

  def render_results(game)
    render(partial: 'shared/results_display', locals: {game: game}, async: true)
  end

  def final_poolplay_standings(teams)
    sort_teams_by_record_points(teams)
  end
end
