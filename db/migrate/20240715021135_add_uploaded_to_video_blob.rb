class AddUploadedToVideoBlob < ActiveRecord::Migration[7.1]
  def change
    add_column :video_blobs, :uploaded_on, :datetime
  end
end
