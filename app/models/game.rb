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

    update_records(winners, diff, true) # bool for if teams array passed in were the winners
    update_records(losers, diff, false)
  end

  def update_play_for_editing(tourn_type, playoffs)
    diff = find_differential
    winners = self.winner
    losers = find_losers

    update_records_for_editing(winners, diff, true)
    update_records_for_editing(losers, diff, false)
  end

  # updates differential for kob winners and losers, also updates wins and losses
  # in poolplay
  def update_records_for_editing(team, diff, winner)
    if winner
      team.split("/").each do |winner|
        team = Team.find(winner)
        record = team.pool_record.split("-")
        record[0] = record[0].to_i - 1
        team.update(pool_diff: team.pool_diff - diff, pool_record: record.join("-"))
      end
    else
      team.split("/").each do |loser|
        team = Team.find(loser)
        record = team.pool_record.split("-")
        record[1] = record[1].to_i - 1
        team.update(pool_diff: team.pool_diff + diff, pool_record: record.join("-"))
      end
    end
  end

  def update_records(team, diff, winner)
    if winner
      team.split("/").each do |winner|
        team = Team.find(winner)
        record = team.pool_record.split("-")
        record[0] = record[0].to_i + 1
        team.update(pool_diff: team.pool_diff + diff, pool_record: record.join("-"))
      end
    else
      team.split("/").each do |loser|
        team = Team.find(loser)
        record = team.pool_record.split("-")
        record[1] = record[1].to_i + 1
        team.update(pool_diff: team.pool_diff - diff, pool_record: record.join("-"))
      end
    end
  end

  # seeds = {1: [1,4], 2: [3, 5]...}
  def self.save_teams_playoffs_to_database(tourn_id, seeds, version)
    bye = seeds.keys.size % 4 != 0 && version == "playoff"
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

  # takes in all teams in kob format poolplay
  ## sorts by record / point diff
  ### maps to user_ids
  #### in order to create new Team objects for playoffs
  def self.overall_poolplay_kob_rankings(teams)
    teams.sort_by do |team|
      team_wins, team_losses = team.pool_record.split("-").map(&:to_i)
      [team_wins, team.pool_diff]
    end.reverse.map(&:user_id)
  end
end
