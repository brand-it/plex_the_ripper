class CreateEpisodes < ActiveRecord::Migration[6.0]
  def change
    create_table :episodes do |t|
      t.string :name
      t.string :overview
      t.string :still_path
      t.string :file_path
      t.string :workflow_state

      t.integer :episode_number
      t.integer :the_movie_db_id

      t.date :air_date

      t.references :season
      t.references :disk_title
    end
  end
end
