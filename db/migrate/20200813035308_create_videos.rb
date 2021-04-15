class CreateVideos < ActiveRecord::Migration[6.0]
  def change
    create_table :videos do |t|
      t.string :title
      t.string :original_title
      t.date :release_date
      t.string :poster_path
      t.string :backdrop_path
      t.integer :the_movie_db_id
      t.string :overview
      t.date :episode_first_air_date
      t.string :episode_distribution_runtime
      t.integer :movie_runtime
      t.string :type
      t.datetime :synced_on
      t.timestamps
      t.index [:type, :the_movie_db_id], unique: true
    end
  end
end
