class RemoveColumnVersionFromPoolplay < ActiveRecord::Migration[5.2]
  def change
    remove_column :poolplays, :version
  end
end
