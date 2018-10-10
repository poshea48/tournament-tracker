class Poolplay < ApplicationRecord

  belongs_to :tournament
  VALID_SCORE_REGEX = /\A[2]\d+-\d{1,2}\z/
  # validates :score, format: { with: VALID_SCORE_REGEX }

  default_scope { order(court_id: :asc)}

  def self.create_kob_pool(tournament)
    if tournament.teams.length % 4 != 0
      return false
    end
    teams = tournament.teams.map {|team| team.id}
    self.randomly_assign_kob_players_to_courts(teams)
  end


  # takes in a hash of team_ids separated by courts and version (pool or playoff)
  def self.save_kob_to_database(pool, tourn_id, version="pool")
    if pool.nil?
      return false
    end
    result = []
    pool.keys.each do |court|
      teams = randomly_generate_kob_teams(pool[court])
      games = generate_kob_games(teams)
      games.each do |game|
        if version == 'playoff'
          result << Poolplay.create(tournament_id: tourn_id, team_ids: game,
                          court_id: court, version: version)
        else
          result << Poolplay.create(tournament_id: tourn_id, team_ids: game,
                        court_id: court, version: version)
        end
      end
    end
    result.empty? ? false : result
  end

  # refactor these two methods into 1
  # need to fix for different number of courts
  # takes in an array of arrays, each array are Team objects separated by which court they played on
  def self.create_playoffs(tournament_id, playoff_teams)
    playoffs = {}
    winners = []
    losers = []
    if playoff_teams.length == 1
      playoffs[100] = playoff_teams.first.map {|team| team.id}
    else
      playoff_teams.each do |group|
        until group.empty?
          if group.length == 4
            winners << group.shift(2)
          else
            losers << group.shift
          end
        end
      end

      winners.flatten!.sort! {|team1, team2| team2.pool_diff <=> team1.pool_diff}
      if winners.length > 4
        until winners.length == 4
          losers << winners.pop
        end
      end

      winners.sort! {|team1, team2| team2.pool_diff <=> team1.pool_diff}.map! { |team| team.id }
      losers.sort! {|team1, team2| team2.pool_diff <=> team1.pool_diff}.map! { |team| team.id }

      playoffs[100] = winners
      court = 101

      until losers.empty?
        playoffs[court].nil? ? playoffs[court] = losers.shift(4) : playoffs[court] << losers.shift(4)
        playoffs[court].flatten!
        court += 1
      end
    end
    Poolplay.save_kob_to_database(playoffs, tournament_id, 'playoff')
  end

  private

    # separate teams into groups of 4
    # result = {1: [6, 2, 1, 8], 2: [5, 4, 3, 7]}
    # each sub-array represents 4 kob players
    # put this in session and db
    def self.randomly_assign_kob_players_to_courts(teams)
      court = 1
      result = {court => []}
      until teams.empty?
        team = teams.slice!(rand(teams.length))
        if result[court].length == 4
          # result[court] = randomly_generate_kob_teams(result[court])
          court += 1
          result[court] = [team]
        else
          result[court].push(team)
        end
      end
      result
    end

    # randomly pick out 2 teams with different players to create a game, then add to results
    # input => teams = [[1, 2], [1, 3], [1, 4], [2, 3], [2, 4], [3, 4]]
    # return => ["3/4-1/2", "1/4-2/3", "2/4-1/3"]
    def self.generate_kob_games(teams)
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

    # add games to database
    def self.add_games_to_database(court, games, tourn_id)
      games.each do |game|
        Poolplay.create(tournament_id: tourn_id, team_ids: games,
                        court_id: court)
      end
    end

    # randomly create 3 games from a group of 4 teams
    # group = [1, 2, 3, 4]
    # return value = [[1, 2], [1, 3], [1, 4], [2, 3], [2, 4], [3, 4]]
    # each sub array is a team of 2 kob players
    def self.randomly_generate_kob_teams(group)
      group.permutation(2).to_a.map { |team| team.sort() }.uniq
    end

end
