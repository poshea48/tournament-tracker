class CreatePlayoffs < ActiveRecord::Migration[5.2]
  def change
    create_table :playoffs do |t|
      t.integer "tournament_id"
      t.integer "round"
      t.string "team_ids"
      t.string "winner"
      t.timestamps
    end

    add_index :playoffs, :tournament_id, unique: true
  end
end
