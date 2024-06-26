class DropEpisodeDiskTitleId < ActiveRecord::Migration[7.1]
  def up
    remove_column :episodes, :disk_title_id
  end
end
