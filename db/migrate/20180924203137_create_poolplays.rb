class CreatePoolplays < ActiveRecord::Migration[5.2]
  def change
    create_table :poolplays do |t|
      t.belongs_to :tournament, index: true
      t.integer :court_id
      t.string :games
      t.string :winner
      t.string :score

      t.timestamps
    end

    # add_index :poolplays, :tourn_id, unique: true
  end
end
