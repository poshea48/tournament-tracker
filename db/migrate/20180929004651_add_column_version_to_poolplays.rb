class AddColumnVersionToPoolplays < ActiveRecord::Migration[5.2]
  def change
    add_column :poolplays, :version, :string, default: 'pool'
  end
end
