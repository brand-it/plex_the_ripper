class Episode < Model
  columns(number: Integer, season: Season)
  validate_presence(:number)
  validate_presence(:season)
end
