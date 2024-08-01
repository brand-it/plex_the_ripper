class AddUploadableStatusToVideoBlob < ActiveRecord::Migration[7.1]
  def change
    add_column :video_blobs, :uploadable, :boolean, default: false, null: false
  end
end
