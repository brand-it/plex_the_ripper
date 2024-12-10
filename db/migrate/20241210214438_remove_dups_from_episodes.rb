class RemoveDupsFromEpisodes < ActiveRecord::Migration[7.2]
  def change
    Episode.find_each do |episode|
      episodes = Episode.where(the_movie_db_id: episode.the_movie_db_id)
      if episodes.size > 1
        episodes.each.with_index do |dup, index|
          next if index.zero?
          dup.destroy
        end
      end
    end
    add_index :episodes, [:the_movie_db_id], if_not_exists: true, unique: true
  end
end
