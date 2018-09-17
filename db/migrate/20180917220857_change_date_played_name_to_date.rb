class ChangeDatePlayedNameToDate < ActiveRecord::Migration[5.2]
  def change
    rename_column :tournaments, :date_played, :date
  end
end
