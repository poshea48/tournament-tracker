class Tournament < ApplicationRecord
  validates :name, presence: true
  validates :date_played, presence: true
end
