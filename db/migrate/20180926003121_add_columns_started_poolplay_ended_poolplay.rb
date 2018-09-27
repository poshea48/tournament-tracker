class AddColumnsStartedPoolplayEndedPoolplay < ActiveRecord::Migration[5.2]
  def change
    add_column :tournaments, :poolplay_started, :boolean, default: false
    add_column :tournaments, :poolplay_finished, :boolean, default: false
  end
end
