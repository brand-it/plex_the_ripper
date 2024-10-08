class AddDescriptionToDiskTitles < ActiveRecord::Migration[7.2]
  def change
    add_column :disk_titles, :description, :string
  end
end
