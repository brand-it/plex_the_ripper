# frozen_string_literal: true

class AskForVideoDetails
  attr_accessor :config

  def initialize
    self.config = Config.configuration
  end

  class << self
    def perform
      ask_for_video_details = AskForVideoDetails.new
      ask_for_video_details.ask_for_video_name
      Logger.info(
        "Name of #{Config.configuration.type} is going to be #{Config.configuration.video_name.inspect}"
      )
    end
  end

  def video_name_present?
    config.video_name.to_s != ''
  end

  def ask_for_video_name
    until video_name_present?
      config.video_name = Shell.ask_value_required(
        "What is the Name of this #{config.type}: ", type: String
      ) do
        Logger.info(config.selected_disc_info.reload.describe) if config.selected_disc_info
      end
    end
  end
end
