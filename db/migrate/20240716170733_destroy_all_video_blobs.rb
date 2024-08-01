class DestroyAllVideoBlobs < ActiveRecord::Migration[7.1]
  def change
    VideoBlob.destroy_all
  end
end
