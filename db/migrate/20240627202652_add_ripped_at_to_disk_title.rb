class AddRippedAtToDiskTitle < ActiveRecord::Migration[7.1]
  def change
    add_column :disk_titles, :ripped_at, :datetime
  end
end
