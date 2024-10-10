# frozen_string_literal: true

require 'ruby-progressbar/projectors/smoothed_average'

module ProgressTracker
  class Projector
    DEFAULT_PROJECTOR     = ProgressBar::Projectors::SmoothedAverage
    NAME_TO_PROJECTOR_MAP = {
      'smoothed' => ProgressBar::Projectors::SmoothedAverage
    }.freeze

    def self.from_type(name)
      NAME_TO_PROJECTOR_MAP.fetch(name, DEFAULT_PROJECTOR)
    end
  end
end
