class CreateSeasons < ActiveRecord::Migration[6.0]
  def change
    create_table :seasons do |t|
      t.string :name
      t.string :overview
      t.string :poster_path
      t.integer :the_movie_db_id
      t.integer :season_number
      t.date :air_date
      t.references :tv
      t.timestamps
    end
  end
end
