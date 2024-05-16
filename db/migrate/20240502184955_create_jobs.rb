class CreateJobs < ActiveRecord::Migration[7.1]
  def change
    create_table :jobs do |t|
      t.datetime :ended_at
      t.datetime :started_at
      t.string :error_class
      t.string :error_message
      t.string :name, null: false
      t.string :status, null: false, default: 'enqueued'
      t.text :arguments
      t.text :backtrace
      t.timestamps
    end
  end
end
