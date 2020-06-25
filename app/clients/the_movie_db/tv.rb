# frozen_string_literal: true

module TheMovieDB
  class TV < Model
    attr_accessor(:loaded)
    columns(
      seasons: Array,
      id: Integer,
      episode_run_time: Array,
      name: String,
      first_air_date: String,
      url: String
    )
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

    # TV show use name this helps normalize the data
    def name
      return @name unless release_date_present?
      "#{@name} (#{release_date_to_time.year})"
    end


    def release_date_to_time
      @release_date_to_time ||= Time.parse(first_air_date)
    end

    def release_date_present?
      first_air_date.to_s != ''
    end

    def runtime
      load_more
      { min: episode_run_time.min, max: episode_run_time.max }
    end

    def find_season_by_number(number)
      return if number.nil?
      load_more
      seasons.find { |s| s.season_number == number }
    end

    def seasons=(values)
      @seasons = values.to_a.map do |value|
        value[:tv] = self
        Season.new(value)
      end
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
