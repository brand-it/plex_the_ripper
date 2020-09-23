class CreateDiskTitles < ActiveRecord::Migration[6.0]
  def change
    create_table :disk_titles do |t|
      t.string :name, null: false
      t.integer :duration
      t.integer :title_id, null: false
      t.float :size
      t.references :disk
      t.timestamps
    end
  end
end
