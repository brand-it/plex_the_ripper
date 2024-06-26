class AddVideoToDisk < ActiveRecord::Migration[7.1]
  def change
    add_reference :disks, :video, polymorphic: true
  end
end
