class Tournament < ApplicationRecord
  include PoolplaysHelper
  has_many :teams, dependent: :destroy
  has_many :users, through: :teams
  has_many :games, dependent: :destroy

  validates :name, presence: true
  validates :date, presence: true
  validates :tournament_type, presence: true

  def sort_teams_by_points
    self.teams.sort {|a, b| b.total_points <=> a.total_points}
  end

  def poolplays
    self.games.select { |game| game.version == 'poolplay'}
  end

  def playoffs
    self.games.select { |game| game.version == 'playoff'}
  end

  # final results for kob tournament
  def final_results_list
    results = []
    playoffs = self.playoffs

    if self.tournament_type == 'kob'
      results = get_final_placings_kob(playoffs)
    else
      results = get_final_placings_team_play(playoffs)
    end
    results
  end

  private

  #takes in Game object
  #returns an array of teams [1, 2, 4, 5]
  def get_team_ids(game)
    team_ids = game.team_ids # "1/2-4/5"
    team_ids.split("-").map do |team| #["1/2", "4/5"]
      team.split("/")
    end.flatten.map(&:to_i)
  end

    # takes in array of Games objects where version == 'playoffs'
    def get_final_placings_kob(games)
      winners_court_team_ids = get_team_ids(games.select {|game| game.court_id == 100}.first)

      winners = winners_court_team_ids.map do |team_id|
        self.teams.select {|team| team.id == team_id}.first
      end.sort { |team1, team2| team2.playoffs.to_i <=> team1.playoffs.to_i }
      if games.length > 3 # for more than 1 court(3 games per court for kob)
        losers_court_team_ids = get_team_ids(games.select { |pool| pool.court_id != 100}.first)

        # takes all teams that were not on winners courts and sorts them by diff regardless of which court they were on
        # update to sort by court first then points
        the_rest = losers_court_team_ids.map do |team_id|
          self.teams.select {|team| team.id == team_id}.first

          # Team.find(team_id)
        end.sort { |team1, team2| team2.playoffs.to_i <=> team1.playoffs.to_i }

        third_place = the_rest.shift

        winners.insert(2, third_place).concat(the_rest)
      end
      winners
    end

      # takes all playoff game instances
      # [{id, tourn_id, round, team_ids, winner}, ...]
      def get_final_placings_team_play(playoff_games)
        all_seeds = playoff_games.select {|game| game.round == 1}.map do |game|
           game.team_ids.split(",")
        end.flatten

        results = []

        sorted_by_round = playoff_games.sort {|game1, game2| game2.round <=> game1.round}
        i = 0
        until sorted_by_round.empty?
          break if sorted_by_round[i].nil?
          seeds = sorted_by_round[i].team_ids.split(",") #in team play, team_ids will be seed #s
          next_in = seeds.select {|seed| !results.include?(seed)}

          if results.empty?
            winner = sorted_by_round[i].winner
            loser = seeds.select {|seed| seed != winner}.first
            results.push(winner, loser)
          elsif next_in
            results.push(next_in)
            results.flatten!
          end
          sorted_by_round.shift
          i += 1
        end
        results.flatten!
        all_seeds.each do |seed|
          results.push(seed) if !results.include?(seed)
        end
        results
      end
end
