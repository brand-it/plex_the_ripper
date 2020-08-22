# frozen_string_literal: true

class TheMovieDbTvListener
  PERMITTED_PARAMS = %i[name original_name year poster_path backdrop_path overview episode_run_time].freeze

  def tv_saving(tv) # rubocop:disable Naming/MethodParameterName
    return if tv.the_movie_db_id.nil?

    db_tv = TheMovieDb::Tv.new(tv.the_movie_db_id).results
    tv.attributes = tv_params(db_tv)
  end

  private

  def tv_params(db_tv)
    db_tv.to_h.slice(*PERMITTED_PARAMS)
  end
end
