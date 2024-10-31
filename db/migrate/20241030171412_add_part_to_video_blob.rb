class AddPartToVideoBlob < ActiveRecord::Migration[7.2]
  def change
    add_column :video_blobs, :part, :integer
  end
end
