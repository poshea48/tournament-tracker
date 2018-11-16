class DropPlayoffs < ActiveRecord::Migration[5.2]
  def change
    drop_table :playoffs
  end
end
