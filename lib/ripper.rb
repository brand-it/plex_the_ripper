# frozen_string_literal: true

require File.expand_path('base', __dir__).to_s

class Ripper
  extend TimeHelper
  extend HumanizerHelper
  class Abort < RuntimeError; end
  class Terminate < RuntimeError; end

  class << self
    def perform
      Thread.report_on_exception = Config.configuration.verbose
      Thread.abort_on_exception = true
      threads = []
      threads << Thread.new do
        AskForDiscSelector.perform
        AskForFilePathBuilder.perform
        AskForVideoDetails.perform
        AskForMovieDetails.perform
        AskForTVDetails.perform
      end
      threads << Thread.new { VideosLoader.perform }
      threads << Thread.new { LoadDiscDetails.perform }
      threads.each(&:join)
      Shell.puts_buffer
      DuplicateChecker.perform
      CreateMKV::Movie.perform
      CreateMKV::TV.perform
      Config.configuration.selected_disc_info.eject
      Config.configuration.reset!
      Ripper.perform
    rescue Ripper::Abort => exception
      threads.each { |t| Thread.kill t }
      Logger.warning(exception.message)
      Config.configuration.selected_disc_info.eject
      Config.configuration.reset!
      Ripper.perform
    rescue Ripper::Terminate => exception
      Logger.error(exception.message)
      threads.each { |t| Thread.kill t }
    end

    def fixer
      VideosLoader.perform
      FixTVShowNames.perform
    rescue Ripper::Abort => exception
      threads.each { |t| Thread.kill t }
      Logger.warning(exception.message)
      Config.configuration.selected_disc_info.eject
      Config.configuration.reset!
      Ripper.perform
    rescue Ripper::Terminate => exception
      Logger.error(exception.message)
      threads.each { |t| Thread.kill t }
    end
  end
end
