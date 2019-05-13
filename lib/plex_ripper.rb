# frozen_string_literal: true

require File.expand_path('base', __dir__).to_s

module Plex
  class Ripper
    extend TimeHelper
    extend HumanizerHelper
    class Abort < RuntimeError; end
    class Terminate < RuntimeError; end

    class << self
      def terminate
        return unless @threads

        @threads.each { |t| Thread.kill t }
        @threads = []
      end

      def rip_video
        Downloadtools::MKVmaker.download
        Thread.report_on_exception = Config.configuration.verbose if Thread.respond_to?(:report_on_exception)
        Thread.abort_on_exception = true
        @threads = []
        @threads << Thread.new do
          AskForDiscSelector.perform
          AskForFilePathBuilder.perform
          AskForVideoDetails.perform
          AskForMovieDetails.perform
          AskForTVDetails.perform
        end
        @threads << Thread.new { VideosLoader.perform }
        @threads << Thread.new { LoadDiscDetails.perform }
        @threads.each(&:join)
        Shell.puts_buffer
        DuplicateChecker.perform
        CreateMKV::Movie.perform
        CreateMKV::TV.perform
        Config.configuration.selected_disc_info.eject
        Config.configuration.reset!
        Ripper.rip_video
      rescue Ripper::Abort => exception
        terminate
        Logger.warning(exception.message)
        Config.configuration.selected_disc_info.eject
        Config.configuration.reset!
        Ripper.rip_video
      rescue Ripper::Terminate => exception
        Logger.error(exception.message)
        terminate
      end

      def perform
        Notification.slack(
          'Slack Hooks Ready',
          'Cool slack is setup and ready to go. '\
          'It will send you notifications on updates in the ripping process to this channel'
        ) # there is a check in this tool it will not work if the webhook is not setup correctly
        Logger.info("Logs are stored here: #{Config.configuration.log_directory}")
        rip_video
      end

      def swapper
        AskForFilePathBuilder.perform
        VideosLoader.perform
        Swap.perform
        Ripper.swapper
      rescue Ripper::Abort => exception
        terminate
        Logger.warning(exception.message)
        Ripper.swapper
      rescue Ripper::Terminate => exception
        Logger.error(exception.message)
        terminate
      end

      def fixer
        VideosLoader.perform
        FixTVShowNames.perform
      rescue Ripper::Abort => exception
        terminate
        Logger.warning(exception.message)
      rescue Ripper::Terminate => exception
        Logger.error(exception.message)
        terminate
      end
    end
  end
end