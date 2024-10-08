class AddAngelToDiskTitles < ActiveRecord::Migration[7.2]
  def change
    add_column :disk_titles, :angle, :integer
  end
end
