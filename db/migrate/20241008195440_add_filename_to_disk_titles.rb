class AddFilenameToDiskTitles < ActiveRecord::Migration[7.2]
  def change
    add_column :disk_titles, :filename, :string
  end
end
