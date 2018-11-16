class CreateGames < ActiveRecord::Migration[5.2]
  def change
    create_table :games do |t|
      t.integer "tournament_id"
      t.integer "court_id"
      t.integer "round"
      t.string "team_ids"
      t.string "winner"
      t.string "version"
      t.timestamps
    end

    add_index :games, :tournament_id
  end
end
