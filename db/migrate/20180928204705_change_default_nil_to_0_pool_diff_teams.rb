class ChangeDefaultNilTo0PoolDiffTeams < ActiveRecord::Migration[5.2]
  def change
    change_column_default(:teams, :pool_diff, from: nil, to: 0)
  end
end
