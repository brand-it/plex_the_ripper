class CreateDisks < ActiveRecord::Migration[6.0]
  def change
    create_table :disks do |t|
      t.string :name
      t.string :disk_name
      t.string :workflow_state
      t.timestamps
    end
  end
end
