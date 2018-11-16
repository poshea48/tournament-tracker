class AddColumnScoreToGames < ActiveRecord::Migration[5.2]
  def change
    add_column :games, :score, :string 
  end
end
