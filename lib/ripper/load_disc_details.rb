# frozen_string_literal: true

class LoadDiscDetails
  class << self
    def perform
      sleep 1 while Config.configuration.selected_disc_info.nil?
      details = Config.configuration.selected_disc_info.details

      return if details || details.any?

      raise Plex::Ripper::Terminate, 'Failed to load disc something really bad happened'
    end
  end
end
