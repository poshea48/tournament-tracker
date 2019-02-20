class ChangePlayoffsToBeBooleanInTeam < ActiveRecord::Migration[5.2]
  def change
    change_column :teams, :playoffs, :boolean, default: false
  end
end
