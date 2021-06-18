class CreateMkvProgresses < ActiveRecord::Migration[6.0]
  def change
    create_table :mkv_progresses do |t|
      t.string :name
      t.float :percentage
      t.datetime :completed_at
      t.datetime :failed_at
      t.text :message

      t.references :disk_title
      t.references :disk
      t.references :progressable, polymorphic: true
      t.timestamps
    end
  end
end
