class AddTypeToTournaments < ActiveRecord::Migration[5.2]
  def change
    add_column :tournaments, :type, :string
  end
end
