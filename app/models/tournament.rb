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

  # get all poolplay Game objects
  def poolplay_games
    self.games.select { |game| game.version == 'poolplay'}
  end

  # get all playoff Game objects
  def playoff_games
    self.games.select { |game| game.version == 'playoff'}
  end

  # get all Team objects from poolplay
  def poolplay_team_objects
    self.teams.select { |team| !team.playoffs }
  end

  def poolplay_team_ids
    self.teams.select {|team| !team.playoffs }.map { |team| team.id }
  end

  # selects Team objects based on court id
  ## then sorts teams based on record then point differential
  def get_court_standings(court_id, playoff_bool)
    sort_group_of_teams(self.teams.select {|team| team.court_id == court_id && team.playoffs == playoff_bool })
  end

  # final results for kob tournament
  def final_results_list
    winners = sort_group_of_teams(self.teams.select { |team| team.playoffs && team.court_id == 100 })
    losers = sort_group_of_teams(self.teams.select { |team| team.playoffs && team.court_id != 100 })

    #only for kob, game play will not have a losers court
    ## winner of consolation court kob, become overall 4th place
    if (losers)
      third_place = losers.shift
      winners.insert(3, third_place).concat(losers)
    end
    winners
  end

  #######  CREATE AND SAVE DIFFERENT PLAY TYPES ###############

  # creates a hash for initial kob poolplay round
  # randomly assigns team_ids to courts, with 4 teams/players to a court
  def create_random_kob_poolplay
    if self.teams.length % 4 != 0
      return false
    end
    randomly_assign_kob_players_to_courts(self.poolplay_team_ids)
    ##{1: [3, 4, 8, 5], 2: [1, 2, 7, 6]}
  end

  # Creates team object for poolplay
  ##
  def create_team_poolplay
    pool = self.poolplay_teams # Team objects
    save_team_play_to_database(tournament_id, pool, "poolplay")
  end

  # creates playoffs games when tournament_type is set to kob
  ## takes in teams array already sorted by record and diff
  def create_kob_playoffs
    playoffs = {}
    court = 100
    sorted_users = self.final_poolplay_rankings # returns Team objects
    until sorted_users.empty?
      teams = sorted_users.shift(4).map do |team|
        save_kob_team_to_database(team.user_id, team.team_name, court, true)
      end
      playoffs[court] = teams
      court += 1
    end
    # playoffs => {100: [Teamobjects], 101: [Team_objects]}
    ## => transform into { 100: [team_ids...], 101: [team_ids]}
    ###
    playoffs.keys.each do |court|
      playoffs[court].map! {|team| team.id}
    end
    # create new Team objects for playoffs
    # creates a hash with court ids as keys and array of team ids as values
    # playoffs = hash of team ids separated by court number
    self.save_kob_games_to_database(playoffs, "playoff")
  end

  def final_poolplay_rankings
    sort_group_of_teams(self.poolplay_team_objects)
  end

  def final_poolplay_rankings_by_user_id
    final_poolplay_rankings.map {|team| team.user_id}
  end

  # creates playoffs games when tournament_type is set to kob/team
  ## takes in array of array of Team objects already sorted
  ### return an array of arrays of team ids sorted by record and diff
  def create_teams_from_kob_playoffs
    seeds = {}
    seed = 1
    sorted_teams = final_poolplay_rankings_by_user_id
    # creates an array of all teams in tournament sorted by record then points
    until sorted_teams.empty?
      ## remove first 2 teams
      ## create a new Team object with
      player1_id, player2_id = sorted_teams.shift(2)
      Team.create()
      seeds[seed] = sorted_teams.shift(2)
      seed += 1
    end
    seeds # hash seed num as keys and array of 2 team ids as value
    save_teams_playoffs_to_database(tournament.id, seeds, "playoffs")
  end

  # creates playoffs games when tournament_type is set to team
  def create_teams_from_teams_playoffs()
  end

  # used to save Game objects all tourn_types
  ## pool = {100 => ["3/4-1/2", "1/4-2/3", "2/4-1/3"], 101 => ...}
  ### version => poolplay or playoff
  def save_kob_games_to_database(pool, version)
    pool.keys.each do |group|
      #["3/4-1/2", "1/4-2/3", "2/4-1/3"]
      generate_kob_games(pool[group]).each do |game|
        if Game.create( tournament_id: self.id,
                        team_ids: game,
                        court_id: group,
                        version: version)
        else
          return false
        end
      end
    end
    true
  end

  # takes in hash of court_ids as keys and array of team_ids as properties
  ## updates Team court_id field
  ### used when creating random kob courts before starting poolplay
  def update_team_court_id(pool)
    pool.keys.each do |court_id|
      pool[court_id].each do |team_id|
        Team.find_by_id(team_id.to_i)
          .update(court_id: court_id)
      end
    end
  end

  def save_kob_team_to_database(player_id, team_name, court_id, version)
    Team.create(user_id: player_id, tournament_id: self.id,
                team_name: team_name, court_id: court_id, playoffs: version )
  end

  def points_earned_kob
    num_of_teams = self.teams.select { |team| team.playoffs }.length
    if num_of_teams == 4
      return [100, 50, 25, 20]
    else
      points = [100, 50, 25, 20, 20]
      until points.length == num_of_teams
        points << 10
      end
      return points
    end
  end

  def end
    self.update!(closed: true)
    teams = self.final_results_list
    points = self.points_earned_kob
    # private method
    update_users_points(teams, points)
  end

  private

  def sort_group_of_teams(teams)
    teams.sort_by  do |team|
      team_wins, team_losses = team.pool_record.split("-").map(&:to_i)
      [team_wins, team.pool_diff]
    end.reverse
  end
  #takes in Game object
  #returns an array of teams [1, 2, 4, 5]
  def get_team_ids(game)
    team_ids = game.team_ids # "1/2-4/5"
    team_ids.split("-").map do |team| #["1/2", "4/5"]
      team.split("/")
    end.flatten.map(&:to_i)
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

  def randomly_assign_kob_players_to_courts(teams)
    court = 1
    result = {court => []}
    until teams.empty?
      team = teams.slice!(rand(teams.length))
      if result[court].length == 4
        court += 1
        result[court] = [team]
      else
        result[court].push(team)
      end
    end
    result #{1: [3, 4, 8, 5], 2: [1, 2, 7, 6]}
  end

  def generate_kob_games(group)
    teams = group.permutation(2).to_a.map { |team| team.sort() }.uniq
    #teams = [[1, 2], [1, 3], [1, 4], [2, 3], [2, 4], [3, 4]]
    games = []
    until teams.empty? do
      team1 = teams.slice!(rand(teams.length))
      team2 = nil
      while team2.nil? || team2.any? { |player| team1.include?(player) } do
        random_index = rand(teams.length)
        team2 = teams[random_index]
      end
      teams.slice!(random_index)
      game = "#{team1[0]}/#{team1[1]}-#{team2[0]}/#{team2[1]}"
      games.push(game)
    end
    games
  end

  def update_users_points(teams, points)
    teams.each_with_index do |team, i|
      user = team.user
      team.update!(place: i + 1)
      user.update!(points: user.points + points[i])
    end
  end
end
