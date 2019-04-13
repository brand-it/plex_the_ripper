# frozen_string_literal: true

module TheMovieDB
  class TV < Model
    attr_accessor(:loaded)
    columns(seasons: Array, id: Integer, episode_run_time: Array, name: String, first_air_date: String)
    validate_presence(:id)

    class << self
      include TheMovieDBAPI

      def search(query, page: 1)
        super(page: page, query: query, type: :tv).map do |tv_show|
          TV.new(tv_show)
        end
      end

      def find(id)
        tv_show = video(type: :tv, id: id)
        return if tv_show.nil?

        TV.new(tv_show)
      end
    end

    def runtime
      load_more
      { min: episode_run_time.min, max: episode_run_time.max }
    end

    def find_season_by_number(number)
      return if number.nil?

      season = seasons.find { |s| s['season_number'].to_i == number }
      return if season.nil?

      season[:tv] = self
      Season.new(season)
    end

    # load more of the data if more is needed. This is useful for in the
    # case of runtime not being present
    def load_more
      return if loaded

      update(TV.video(type: :tv, id: id))
      self.loaded = true
    end

  end
end
