class CreateVideos < ActiveRecord::Migration[6.0]
  def change
    create_table :movies do |t|
      t.string :title
      t.string :original_title
      t.string :workflow_state
      t.date :release_date
      t.string :poster_url
      t.string :backdrop_url
      t.integer :the_movie_db_id
      t.string :overview
      t.string :file_path
      t.belongs_to :disk
      t.timestamps
    end
  end
end
