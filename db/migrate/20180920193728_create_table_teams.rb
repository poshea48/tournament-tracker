class CreateTableTeams < ActiveRecord::Migration[5.2]
  def change
    create_table :teams do |t|
      t.belongs_to :user, index: true
      t.belongs_to :tournament, index: true
      t.integer :player2_id
      t.string :team_name
    end
  end
end
