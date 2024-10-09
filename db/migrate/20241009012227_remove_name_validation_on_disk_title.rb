class RemoveNameValidationOnDiskTitle < ActiveRecord::Migration[7.2]
  def change
    DiskTitle.destroy_all

    change_column_null :disk_titles, :name, true
    change_column_null :disk_titles, :filename, false
  end
end
