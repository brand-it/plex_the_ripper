# frozen_string_literal: true

module TheMovieDb
  class Api
    # This build a bunch of uniq names that can be used to build the names of the files.
    # These uniq names work best as they play nice with the Plex data and plus then you can
    # tell if you have which movie is from 1999 and 2032.
    # Example:
    #   uniq_names(search('dark'))
    #
    def uniq_names(search_results)
      names_hash = Hash.new(0)
      search_results.map do |result|
        names_hash[result.name] += 1
        if names_hash[result.name] > 1
          extra_info = result.release_date_present? ? result.release_date_to_time.year : result.id
          "#{result.name} (#{extra_info})"
        else
          result.name
        end
      end
    end

    def video(type:, id:)
      request("#{type}/#{id}")
    end
  end
end
