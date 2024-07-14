class RemoveColumnSyncedOn < ActiveRecord::Migration[7.1]
  def change
    remove_column :videos, :synced_on, :datetime
  end
end
