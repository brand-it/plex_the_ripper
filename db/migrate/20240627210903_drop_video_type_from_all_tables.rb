class DropVideoTypeFromAllTables < ActiveRecord::Migration[7.1]
  def change
    remove_column :disk_titles, :video_type
    remove_column :disks, :video_type
    remove_column :video_blobs, :video_type
  end
end
