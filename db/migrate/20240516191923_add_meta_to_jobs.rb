class AddMetaToJobs < ActiveRecord::Migration[7.1]
  def change
    add_column :jobs, :metadata, :text, default: '{}', null: false
  end
end
