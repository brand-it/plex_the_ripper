class AddExtraTypeNumberToVideoBlob < ActiveRecord::Migration[7.1]
  def change
    VideoBlob.destroy_all
    add_column :video_blobs, :extra_type_number, :integer
  end
end
