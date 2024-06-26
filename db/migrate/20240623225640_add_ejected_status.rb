class AddEjectedStatus < ActiveRecord::Migration[7.1]
  def change
    add_column :disks, :ejected, :boolean, null: false, default: true
  end
end
