class DropServiceNameFromVideoBlobs < ActiveRecord::Migration[7.1]
  def up
    remove_column :video_blobs, :service_name
  end

  def down
    add_column :video_blobs, :service_name, :string
  end
end
