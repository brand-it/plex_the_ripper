class CreateDiskTitles < ActiveRecord::Migration[6.0]
  def change
    create_table :disk_titles do |t|
      t.string :name
      t.integer :duration
      t.integer :title_id
      t.float :size
      t.belongs_to :disk
      t.timestamps
    end
  end
end
