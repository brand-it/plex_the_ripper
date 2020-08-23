class CreateTvs < ActiveRecord::Migration[6.0]
  def change
    create_table :tvs do |t|
      t.string :name
      t.string :original_name
      t.string :first_air_date
      t.string :poster_path
      t.string :backdrop_path
      t.integer :the_movie_db_id
      t.string :episode_run_time
      t.string :overview
      t.belongs_to :disk
      t.timestamps
    end
  end
end
