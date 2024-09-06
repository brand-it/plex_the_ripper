class AddAutoStartToDisk < ActiveRecord::Migration[7.2]
  def change
    add_column :videos, :auto_start, :boolean, default: false, null: false
  end
end
