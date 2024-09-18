class CleanupDatabaseForNewParser < ActiveRecord::Migration[7.2]
  def change
    VideoBlob.destroy_all
    Video.destroy_all
  end
end
