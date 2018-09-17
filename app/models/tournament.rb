class Tournament < ApplicationRecord
  validates :name, presence: true
  validates :date, presence: true
  validates :tournament_type, presence: true
end
