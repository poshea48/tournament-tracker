class ChangePoolplayColumnNameFromGamesToTeamIds < ActiveRecord::Migration[5.2]
  def change
    rename_column :poolplays, :games, :team_ids
  end
end
