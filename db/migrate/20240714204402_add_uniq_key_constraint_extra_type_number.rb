class AddUniqKeyConstraintExtraTypeNumber < ActiveRecord::Migration[7.1]
  def change
    add_index :video_blobs, [:extra_type_number, :video_id, :extra_type], unique: true
  end
end
