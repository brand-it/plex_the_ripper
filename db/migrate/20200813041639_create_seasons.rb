class CreateSeasons < ActiveRecord::Migration[6.0]
  def change
    create_table :seasons do |t|
      t.string :name
      t.string :overview
      t.string :poster_url
      t.integer :the_movie_db_id
      t.integer :seasons_number
      t.date :air_date
      t.belongs_to :tv
      t.timestamps
    end
  end
end
