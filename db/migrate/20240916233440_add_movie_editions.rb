class AddMovieEditions < ActiveRecord::Migration[7.2]
  def change
    add_column :video_blobs, :edition, :string
  end
end
