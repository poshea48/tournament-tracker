module TournamentsHelper
  def ready_to_start_poolplay?
    !@tournament.poolplay_started && !@tournament.registration_open &&
    (@tournament.teams.length > 0 && @tournament.teams.length % 4 == 0)
  end
end
