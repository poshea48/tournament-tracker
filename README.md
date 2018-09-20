
Need to dos....
  - Implement remember me test
  x admin access (done)
  x non-admin access (done)
  - add teams to tournament
  - cap # of teams, close registration
  - pool-play page, options of which style of play
  - game results with point diff.
  - rankings
  - pool play ends => seed for playoffs
  - playoff bracket with teams
  - results
  - winner and points distributed
  - close tournament

Team
  - belongs_to :user, index: true
  - belongs_to :tournament, index: true
  -
  - user_id
  - partner_id (could be blank for kob)
  - team_name
  - tournament_id
