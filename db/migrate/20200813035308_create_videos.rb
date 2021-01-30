class CreateVideos < ActiveRecord::Migration[6.0]
  def change
    create_table :videos do |t|
      t.string :title
      t.string :original_title
      t.string :workflow_state
      t.date :release_date
      t.string :poster_path
      t.string :backdrop_path
      t.integer :the_movie_db_id
      t.string :overview
      t.date :first_air_date # Tv Show
      t.string :episode_run_time # Tv Show
      t.string :type
      t.datetime :synced_on
      t.timestamps
      t.index [:type, :the_movie_db_id], unique: true
    end
  end
end
