class AddVideoUniqValidation < ActiveRecord::Migration[7.1]
  def change
    Video.in_batches.destroy_all
    add_index :videos, [:type, :the_movie_db_id], if_not_exists: true, unique: true
  end
end
