class AddColumnPoolplayRecordToTeams < ActiveRecord::Migration[5.2]
  def change
    add_column :teams, :pool_record, :string, default: '0-0'
  end
end
