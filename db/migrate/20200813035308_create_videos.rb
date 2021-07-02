class CreateVideos < ActiveRecord::Migration[6.0]
  def change
    create_table :videos do |t|
      t.string :title
      t.string :original_title
      t.string :poster_path
      t.string :backdrop_path
      t.string :overview
      t.string :type
      t.string :episode_distribution_runtime, array: true
      t.integer :the_movie_db_id
      t.integer :movie_runtime
      t.date :release_date
      t.date :episode_first_air_date
      t.datetime :synced_on
      t.references :disk_title
      t.timestamps
      t.index [:type, :the_movie_db_id], unique: true
    end
  end
end
