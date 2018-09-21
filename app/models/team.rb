class Team < ApplicationRecord
  belongs_to :user
  belongs_to :tournament

  def total_points
    player1_points = User.find(self.user_id).points
    player2_points = (self.player2_id.nil? ? 0 : User.find(self.player2_id).points)
    player1_points + player2_points
  end
end
