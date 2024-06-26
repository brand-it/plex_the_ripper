class RemoveDiskTitleFromVideo < ActiveRecord::Migration[7.1]
  def change
    remove_column :videos, :disk_title_id, :integer
    add_reference :disk_titles, :video, polymorphic: true
    add_reference :disk_titles, :episode
  end
end
