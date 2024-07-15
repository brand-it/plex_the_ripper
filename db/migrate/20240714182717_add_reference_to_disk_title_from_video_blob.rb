class AddReferenceToDiskTitleFromVideoBlob < ActiveRecord::Migration[7.1]
  def change
    add_reference :disk_titles, :video_blob
  end
end
