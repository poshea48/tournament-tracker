class Tournament < ApplicationRecord

  has_many :teams
  has_many :users, through: :teams

  validates :name, presence: true
  validates :date, presence: true
  validates :tournament_type, presence: true
end
