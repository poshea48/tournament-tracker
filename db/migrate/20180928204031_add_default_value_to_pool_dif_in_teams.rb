class AddDefaultValueToPoolDifInTeams < ActiveRecord::Migration[5.2]
  def change
    change_column(:teams, :pool_diff, :integer, default: 0 )
  end
end
