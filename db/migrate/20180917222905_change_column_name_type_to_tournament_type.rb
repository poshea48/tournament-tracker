class ChangeColumnNameTypeToTournamentType < ActiveRecord::Migration[5.2]
  def change
    rename_column :tournaments, :type, :tournament_type
  end
end
