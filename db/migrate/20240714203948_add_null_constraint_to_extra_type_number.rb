class AddNullConstraintToExtraTypeNumber < ActiveRecord::Migration[7.1]
  def change
    change_column_null :video_blobs, :extra_type_number, false
  end
end
