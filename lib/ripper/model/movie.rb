class Movie < Model
  columns(name: String)
  validate_presence(:name)
end
