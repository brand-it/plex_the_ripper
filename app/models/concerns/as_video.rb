# frozen_string_literal: true

module AsVideo
  extend ActiveSupport::Concern
  included do
    class << self
      def find_video(id)
        find_by(the_movie_db_id: id) || find(id)
      end
    end
  end
end
