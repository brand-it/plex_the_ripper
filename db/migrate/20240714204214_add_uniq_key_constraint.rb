class AddUniqKeyConstraint < ActiveRecord::Migration[7.1]
  def change
    add_index :video_blobs, :key, if_not_exists: true, unique: true
  end
end
