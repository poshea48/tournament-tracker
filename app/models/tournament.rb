class Tournament < ApplicationRecord

  has_many :teams
  has_many :users, through: :teams
  has_many :poolplays

  validates :name, presence: true
  validates :date, presence: true
  validates :tournament_type, presence: true

  def sort_teams_by_points
    self.teams.sort {|a, b| b.total_points <=> a.total_points}
  end
end
