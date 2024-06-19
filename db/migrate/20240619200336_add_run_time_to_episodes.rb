class AddRunTimeToEpisodes < ActiveRecord::Migration[7.1]
  def change
    add_column :episodes, :runtime, :integer
  end
end
