require 'rails_helper'
require 'pry'
RSpec.describe Tournament, type: :model do
  context "2 or more users added to a tournament" do
    it "#sort_teams_by_points" do

      @tournament = Tournament.create(name: "Tournament One", date: "9/5/2018", tournament_type: 'kob')
      @player1 = User.create({ first_name: "Player", last_name: "One",
                            email: "player1@example.com", password: 'password',
                            password_confirmation: 'password',
                            admin: true, points: 3
                             })

      @player2 = User.create({ first_name: "Player", last_name: "Two",
                            email: "player2@example.com", password: 'password',
                            password_confirmation: 'password', points: 4 })
      @team1 = Team.create(user_id: @player1.id, tournament_id: @tournament.id, team_name: "#{@player1.first_name} #{@player1.last_name}")
      @team2 = Team.create(user_id: @player2.id, tournament_id: @tournament.id, team_name: "#{@player2.first_name} #{@player2.last_name}")

      expect(@tournament.sort_teams_by_points).to eq([@team2, @team1])
    end
  end
end
