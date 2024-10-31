class AddManyEpisodesPerDisk < ActiveRecord::Migration[7.2]
  def up
    add_reference :disk_titles, :episode_last
    DiskTitle.find_each do |disk_title|
      disk_title.update_column(:episode_last_id, disk_title.episode_id)
    end
  end

  def down
    remove_reference :disk_titles, :episode_last
  end
end
