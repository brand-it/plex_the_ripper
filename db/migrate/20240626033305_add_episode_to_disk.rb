class AddEpisodeToDisk < ActiveRecord::Migration[7.1]
  def change
    add_reference :disks, :episode
  end
end
