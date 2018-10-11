class Tournament < ApplicationRecord
  include PoolplaysHelper
  has_many :teams, dependent: :destroy
  has_many :users, through: :teams
  has_many :poolplays, dependent: :destroy

  validates :name, presence: true
  validates :date, presence: true
  validates :tournament_type, presence: true

  def sort_teams_by_points
    self.teams.sort {|a, b| b.total_points <=> a.total_points}
  end

  def get_pool(pool_id)
    self.poolplays.select { |pool| pool.id == pool_id.to_i }.first
  end

  def get_pools_by_version(version)
    self.poolplays.select { |pool| pool.version == version }
  end

  # final results for kob tournament
  def final_results_list
    results = []
    playoffs = self.poolplays.select {|pool| pool.version == 'playoff'}
    winners_court_team_ids = get_teams_ids_from_court(playoffs.select { |pool| pool.court_id == 100})
    winners = winners_court_team_ids.map do |team_id|
      self.teams.select {|team| team.id == team_id}.first
      # Team.find(team_id)
    end.sort { |team1, team2| team2.playoffs.to_i <=> team1.playoffs.to_i }
    if playoffs.length > 3
      losers_court_team_ids = get_teams_ids_from_court(playoffs.select { |pool| pool.court_id != 100})

      the_rest = losers_court_team_ids.map do |team_id|
        self.teams.select {|team| team.id == team_id}.first

        # Team.find(team_id)
      end.sort { |team1, team2| team2.playoffs.to_i <=> team1.playoffs.to_i }

      third_place = the_rest.shift

      winners.insert(2, third_place).concat(the_rest)
    end
    winners
  end
end
