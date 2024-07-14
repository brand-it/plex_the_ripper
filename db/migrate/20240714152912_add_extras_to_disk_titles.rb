class AddExtrasToDiskTitles < ActiveRecord::Migration[7.1]
  def change
    add_column :video_blobs, :extra_type, :integer, default: 0
  end
end
