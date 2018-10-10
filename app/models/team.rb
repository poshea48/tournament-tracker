class Team < ApplicationRecord
  belongs_to :user
  belongs_to :tournament

  def total_points
    if self.tournament.tournament_type == 'kob'
      return self.user.points
    else
      player1_points = self.user.points
      player2_points = User.find(self.player2_id).points
      return player1_points + player2_points
    end 
  end
end
