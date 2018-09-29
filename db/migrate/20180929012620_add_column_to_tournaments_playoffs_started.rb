class AddColumnToTournamentsPlayoffsStarted < ActiveRecord::Migration[5.2]
  def change
    add_column :tournaments, :playoffs_started, :boolean, default: false 
  end
end
