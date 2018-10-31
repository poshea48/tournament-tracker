class Playoff < ApplicationRecord
  belongs_to :tournament
  VALID_SCORE_REGEX = /\A[2]\d+-\d{1,2}\z/

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
    Playoff.save_kob_to_database(playoffs, tournament_id, playoffs)
  end


end
