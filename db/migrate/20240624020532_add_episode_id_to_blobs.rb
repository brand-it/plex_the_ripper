class AddEpisodeIdToBlobs < ActiveRecord::Migration[7.1]
  def change
    add_column :video_blobs, :episode_id, :bigint
  end
end
