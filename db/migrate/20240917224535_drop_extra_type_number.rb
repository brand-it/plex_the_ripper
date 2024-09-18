class DropExtraTypeNumber < ActiveRecord::Migration[7.2]
  def change
    change_column_null(:video_blobs, :extra_type_number, true)
  end
end
