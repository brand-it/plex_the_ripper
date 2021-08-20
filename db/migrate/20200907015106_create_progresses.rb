class CreateProgresses < ActiveRecord::Migration[6.0]
  def change
    create_table :progresses do |t|
      t.string :key
      t.float :percentage
      t.string :descriptive, null: false
      t.datetime :completed_at
      t.datetime :failed_at
      t.text :message

      t.references :progressable, polymorphic: true
      t.timestamps
    end
  end
end
