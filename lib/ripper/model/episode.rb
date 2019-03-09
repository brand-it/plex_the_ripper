# frozen_string_literal: true

class Episode < Model
  columns(number: Integer, season: Season, file_path: String, name: String)
  validate_presence(:number)
  validate_presence(:season)
  validate_presence(:file_path)
end
