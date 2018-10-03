class Tournament < ApplicationRecord
  include PoolplaysHelper
  has_many :teams
  has_many :users, through: :teams
  has_many :poolplays

  validates :name, presence: true
  validates :date, presence: true
  validates :tournament_type, presence: true

  def sort_teams_by_points
    self.teams.sort {|a, b| b.total_points <=> a.total_points}
  end

  def final_results_list
    winners_court_team_ids = get_teams_ids_from_court(self.poolplays.select { |pool| pool.court_id == 100})
    losers_court_team_ids = get_teams_ids_from_court(self.poolplays.select { |pool| pool.court_id == 101})
    winners = winners_court_team_ids.map do |team_id|
      Team.find(team_id)
    end.sort_by { |team| team.playoffs }.reverse

    the_rest = losers_court_team_ids.map do |team_id|
      Team.find(team_id)
    end.sort_by { |team| team.playoffs }.reverse

    third_place = the_rest.shift

    winners.insert(2, third_place).concat(the_rest)
    
  end
end
