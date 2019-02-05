module HumanizerHelper
  def humanize_disk_info
    if Config.configuration.type == :tv
      [
        Config.configuration.movie_name,
        Config.configuration.tv_season_to_word,
        Config.configuration.disc_number_to_word
      ].reject { |x| x.to_s == '' }.join(' ')
    else
      Config.configuration.movie_name
    end
  end
end