module HumanizerHelper
  NUMBER_TO_WORD = {
    1 => 'one',
    2 => 'two',
    3 => 'three',
    4 => 'four',
    5 => 'five',
    6 => 'six',
    7 => 'seven',
    8 => 'eight',
    9 => 'nine',
    10 => 'ten',
    11 => 'eleven',
    12 => 'twelve',
    13 => 'thirteen',
    14 => 'fourteen',
    15 => 'fifteen',
    16 => 'sixteen',
    17 => 'seventeen',
    18 => 'eighteen',
    19 => 'nineteen',
    20 => 'twenty',
    21 => 'twenty_one',
    22 => 'twenty_two',
    23 => 'twenty_three',
    24 => 'twenty_four',
    25 => 'twenty_five',
    26 => 'twenty_six',
    27 => 'twenty_seven',
    28 => 'twenty_eight',
    29 => 'twenty_nine',
    30 => 'thirty'
  }.freeze

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
