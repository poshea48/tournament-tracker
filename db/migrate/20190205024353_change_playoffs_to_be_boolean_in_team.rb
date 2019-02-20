class ChangePlayoffsToBeBooleanInTeam < ActiveRecord::Migration[5.2]
  def change
    change_column :teams, :playoffs, 'boolean USING CAST(playoffs AS boolean)', default: false
  end
end
