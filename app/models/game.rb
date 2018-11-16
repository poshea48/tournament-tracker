class Game < ApplicationRecord
  include Playable

  belongs_to :tournament, touch: true
  VALID_SCORE_REGEX = /\A[2]\d+-\d{1,2}\z/
  # validates :score, format: { with: VALID_SCORE_REGEX }

  default_scope { order(court_id: :asc)}

  def update_play(tourn_type, playoffs)
    #game = Game instance
    diff = find_differential
    winners = self.winner
    losers = find_losers

    if playoffs && (tourn_type == 'team' || tourn_type == 'kob/team')
      update_team_playoffs(winners)
    else
      update_differential(winners, diff, playoffs, true)
      update_differential(losers, diff, playoffs, false)
    end
  end

  # updats playoffs attribute in Team, for team play team seed - current  round
  # get appended to attribute playoffs
  def update_team_playoffs(winners)
    winners.each do |team|
      team = Team.find(team)
      seed, round = team.playoffs.split(",").last.split("-")
      new_round = team.playoffs + ",#{seed}-#{round.to_i + 1}"
      team.update(playoffs: new_round)
    end
  end

  # updates differential for kob winners and losers, also updates wins and losses
  # in poolplay
  def update_differential(team, diff, playoffs, winner)
    if winner
      team.split("/").each do |winner|
        team = Team.find(winner)
        if playoffs
          player_score = team.playoffs.to_i
          team.update(playoffs: player_score + diff)
        else
          record = team.pool_record.split("-")
          record[0] = record[0].to_i + 1
          team.update(pool_diff: team.pool_diff + diff, pool_record: record.join("-"))
        end
      end
    else
      team.split("/").each do |loser|
        team = Team.find(loser)
        if playoffs
          player_score = team.playoffs.to_i
          team.update(playoffs: player_score - diff)
        else
          record = team.pool_record.split("-")
          record[1] = record[1].to_i + 1
          team.update(pool_diff: team.pool_diff - diff, pool_record: record.join("-"))
        end
      end
    end
  end

  #######  CREATE AND SAVE DIFFERENT PLAY TYPES ###############

  # creates a hash for initial kob poolplay round
  # randomly assigns team_ids to courts, with 4 teams/players to a court
  def self.create_random_kob_poolplay(tournament)
    if tournament.teams.length % 4 != 0
      return false
    end
    teams = tournament.teams.map {|team| team.id}
    randomly_assign_kob_players_to_courts(teams)
    # save_kob_to_database(pool, tournament.id, "poolplay")
    ##{1: [3, 4, 8, 5], 2: [1, 2, 7, 6]}
  end

  def create_random_team_poolplay(tournament)
  end

  # takes in teams array already sorted by record and diff
  # used in self.create_playoffs_group
  def self.create_kob_playoffs(tournament_id, playoff_teams)
    playoffs = {}
    court = 100

    sorted_teams = overall_poolplay_rankings(playoff_teams)
    until sorted_teams.empty?
      playoffs[court] = sorted_teams.shift(4)
      court += 1
    end
    # creates a hash with court ids as keys and array of team ids as values
    # playoffs = hash of team ids separated by court number
    save_kob_to_database(tournament_id, playoffs, "playoff")
  end

  def self.create_team_poolplay(tournament_id, teams)
    pool = #hash with court_ids = [team_ids...]
    save_team_play_to_database(tournament_id, pool, "poolplay")
  end

  #takes in array of array of Team objects already sorted
  #return them seeded based on poolplay record and diff
  def self.create_team_playoffs(tournament_id, teams)
    seeds = {}
    seed = 1
    sorted_teams = overall_poolplay_rankings(playoff_teams)
    until sorted_teams.empty?
      seeds[seed] = sorted_teams.shift(2)
      seed += 1
    end
    seeds # hash seed num as keys and array of 2 team ids as value
    save_team_play_to_database(tournament_id, seeds, "playoffs")
  end

  # # pool = {1: [3, 4, 8, 5], 2: [1, 2, 7, 6]}
  # #playoffs = bool
  # def self.save_pool(pool, tournament, playoffs)
  #   play_type = tournament.tournament_type
  #
  #   if pool.nil?
  #     return false
  #   end
  #
  #   if play_type == 'kob' || (play_type == 'kob/team' && !playoffs)
  #     return save_kob_to_database(pool, tournament.id, playoffs)
  #   else
  #     return save_team_play_to_database(pool, tournament.id, playoffs)
  #   end
  # end
  #
  #
  # #
  # def self.create_kob_playoffs
  #
  # end
  #
  #
  # pool = {1: [3, 4, 8, 5], 2: [1, 2, 7, 6]}

  def self.save_kob_to_database(tourn_id, pool, version)
    pool.keys.each do |group|
      #["3/4-1/2", "1/4-2/3", "2/4-1/3"]
      generate_kob_games(pool[group]).each do |game|
        if Game.create( tournament_id: tourn_id,
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

  # seeds = {1: [1,4], 2: [3, 5]...}
  def self.save_team_play_to_database(tourn_id, seeds, version)
    bye = seeds.keys.size % 4 != 0 && version == "playoff"
    Team.set_playoff_stats(seeds, bye)
    seed_numbers = seeds.keys
    if bye
      seed_numbers.shift(2)
    end

    until seed_numbers.empty?
      team1 = seeds[seed_numbers.shift].join("/")
      team2 = seeds[seed_numbers.pop].join("/")
      if Game.create( tournament_id: tourn_id,
                   round: 1,
                   team_ids: "#{team1}-#{team2}",
                   version: version)
      else
        return false
      end
    end
    true
  end

  private

  def find_differential
    if self.score.nil?
      return 0
    end
    self.score.split("-").map(&:to_i).reduce(:-)
  end

  def find_losers
    teams = self.team_ids.split('-') # '5/6-3/4'['5/6', '3/4']
    teams.select { |team| team != self.winner}.first
  end

  # randomly pick out 2 teams with different players to create a game, then add to results
  # input => group = [1, 2, 3, 4]
  # return => ["3/4-1/2", "1/4-2/3", "2/4-1/3"]
  def self.generate_kob_games(group)
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

  def self.randomly_assign_kob_players_to_courts(teams)
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

  # takes in teams array already sorted by record and diff
  # used in self.create_playoffs_group
  #
  # def self.create_kob_playoffs(tournament_id, playoff_teams)
  #   playoffs = {}
  #   court = 100
  #
  #   sorted_teams = overall_poolplay_rankings(playoff_teams)
  #
  #   until sorted_teams.empty?
  #     playoffs[court] = sorted_teams.shift(4)
  #     court += 1
  #   end
  #   save_kob_to_database(playoffs, tournament_id, true)
  # end

  # takes in


  # takes in array of arrays with team ids already  ranked
  # teams = [[1,2,3,4], [1,2,3,4]]
  # return one array of team ids with overall rankings [1,1,2,2,3,3,4,4] for example

  def self.overall_poolplay_rankings(teams)
    result = []

    loop do
      seeds = []
      teams.each do |court|
        seeds.push(court.shift)
      end

      seeds.sort_by! do |team|
        team_wins, team_losses = team.pool_record.split("-").map(&:to_i)
        [team_wins, team.pool_diff]
      end.reverse!
      result.push(seeds)
      result.flatten
      break if teams.all? {|team| team.empty?}
    end
    result.flatten.map {|team| team.id}
  end
end
