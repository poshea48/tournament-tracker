class AddColumnsPoolDiffPlayoffsToTeams < ActiveRecord::Migration[5.2]
  def change
    add_column :teams, :pool_diff, :integer
    add_column :teams, :playoffs, :string
    add_column :teams, :place, :string
  end
end
