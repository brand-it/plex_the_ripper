class LoadDiscDetails
  class << self
    def perform
      Config.configuration.selected_disc_info.details
    end
  end
end
