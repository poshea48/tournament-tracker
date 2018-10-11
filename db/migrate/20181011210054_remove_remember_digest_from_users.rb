class RemoveRememberDigestFromUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :remember_digest, :string
  end
end
