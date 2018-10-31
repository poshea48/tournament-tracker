module TournamentsHelper
  def ready_to_start_poolplay?
    !@tournament.poolplay_started && !@tournament.registration_open &&
    (@tournament.teams.length > 0 && @tournament.teams.length % 4 == 0)
  end

  def sort_teams_by_points(teams)
    teams.sort {|team1, team2| team2.total_points <=> team1.total_points }
  end
end
