class CreateMkvProgresses < ActiveRecord::Migration[6.0]
  def change
    create_table :mkv_progresses do |t|
      t.string :name
      t.float :percentage
      t.datetime :completed_at
      t.datetime :failed_at

      t.references :video, polymorphic: true
      t.timestamps
    end
  end
end
