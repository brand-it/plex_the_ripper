class CreateEpisodes < ActiveRecord::Migration[6.0]
  def change
    create_table :episodes do |t|
      t.string :name
      t.integer :episode_number
      t.integer :the_movie_db_id
      t.string :overview
      t.string :still_path
      t.date :air_date
      t.string :file_path
      t.string :workflow_state
      t.belongs_to :season
      t.belongs_to :disk
    end
  end
end
