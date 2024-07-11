class AddLoadingToDisks < ActiveRecord::Migration[7.1]
  def change
    add_column :disks, :loading, :boolean, default: false, null: false
  end
end
