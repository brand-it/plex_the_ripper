class LoadDiscDetails
  class << self
    def perform
      sleep 1 while Config.configuration.selected_disc_info.nil?
      Config.configuration.selected_disc_info.details
    end
  end
end
