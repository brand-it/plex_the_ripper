# frozen_string_literal: true

class Movie < Model
  columns(name: String)
  validate_presence(:name)

  class << self
    def mkv_path_to_hash(mkv_path)
      file_name = File.basename(mkv_path, '.mkv').strip
      name = Videos.get_name_from_path(mkv_path, Config.configuration.movies_directory_name)
      { name: name } # should match the columns you want to fill in for this model
    end
  end
end
