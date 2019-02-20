class AddCourtIdColumnToTeams < ActiveRecord::Migration[5.2]
  def change
    add_column :teams, :court_id, :integer 
  end
end
