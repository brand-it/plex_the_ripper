# frozen_string_literal: true

# == Schema Information
#
# Table name: episodes
#
#  id              :integer          not null, primary key
#  air_date        :date
#  episode_number  :integer
#  file_path       :string
#  name            :string
#  overview        :string
#  still_path      :string
#  workflow_state  :string
#  disk_title_id   :bigint
#  season_id       :bigint
#  the_movie_db_id :integer
#
# Indexes
#
#  index_episodes_on_disk_title_id  (disk_title_id)
#  index_episodes_on_season_id      (season_id)
#
class Episode < ApplicationRecord
  belongs_to :season

  belongs_to :disk_title, optional: true

  def plex_path
    raise 'plex config is missing and is required' unless Config::Plex.any?

    @plex_path ||= Pathname.new("#{Config::Plex.newest.settings_tv_path}/#{tv_plex_name}/#{season_name}/#{mkv_file_name}")
  end

  def tmp_plex_dir
    @tmp_plex_dir ||= Rails.root.join("tmp/tv/#{tv_plex_name}/#{season_name}")
  end

  def tmp_plex_path
    @tmp_plex_path ||= tmp_plex_dir.join(mkv_file_name)
  end

  def mkv_file_name
    "#{episode_plex_name} - s#{format_season_number}e#{format_episode_number} - #{name}.mkv"
  end

  def episode_first_air_date
    season.tv.episode_first_air_date
  end

  def title
    season.tv.title
  end

  def season_name
    "Season #{format_season_number}"
  end

  def format_season_number
    format('%02d', season.season_number)
  end

  def format_episode_number
    format('%02d', episode_number)
  end

  def episode_plex_name
    if episode_first_air_date
      "#{title} (#{episode_first_air_date.year}) #{tvdb_id}"
    else
      "#{title} #{tvdb_id}"
    end
  end

  def tv_plex_name
    @tv_plex_name ||= if episode_first_air_date
                        "#{title} (#{episode_first_air_date.year}) #{season.tv.tvdb_id}"
                      else
                        "#{title} #{season.tv.tvdb_id}"
                      end
  end

  def tvdb_id
    "{tvdb-#{the_movie_db_id}}"
  end

  def tmp_plex_path_exists?
    File.exist?(tmp_plex_path)
  end
end
