class AddSegmentMap < ActiveRecord::Migration[7.2]
  def change
    add_column :disk_titles, :segment_map, :string
  end
end
