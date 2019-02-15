class Episode < Model
  columns(number: Integer, season: Season, file_path: String)
  validate_presence(:number)
  validate_presence(:season)
  validate_presence(:file_path)
end
