
Need to dos....
  - Implement remember me test
  x admin access (done)
  x non-admin access (done)
  x add teams to tournament
  x sort teams based on points
  x cap # of teams, close registration
  - pool-play page
    - pool-play db
      - tournament_id, court_id, games (team_id vs team_id),
        winner, score,
    - pool-play controller (index, edit, update)
      - index => create games if not already set up session?
      - pool-play page (index)
      - results form (edit)
    - assigns teams to court
    - randomly select games on each court
    - alert("Happy with this selection?")
  - game results with point diff.
  - rankings
  - pool play ends => seed for playoffs
  - playoff bracket with teams
  - results
  - winner and points distributed
  - close tournament
