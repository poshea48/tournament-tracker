class CreateTournaments < ActiveRecord::Migration[5.2]
  def change
    create_table :tournaments do |t|
      t.string :name
      t.string :date_played
      t.boolean :registration_open, default: true
      t.boolean :closed, default: false
      t.timestamps
    end
  end
end
