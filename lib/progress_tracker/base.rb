# frozen_string_literal: true

require_relative 'time'
require_relative 'timer'
require_relative 'progress'
require_relative 'projector'
require_relative 'projectors/smoothed_average'
require_relative 'component/rate'
require_relative 'component/time'
require_relative 'component/percentage'

module ProgressTracker
  class Base
    extend Forwardable

    def_delegators :progressable,
                   :progress,
                   :total
    def initialize(options = {})
      options[:projector] ||= {}

      self.autostart    = options.fetch(:autostart,  true)
      self.autofinish   = options.fetch(:autofinish, true)
      self.finished     = false

      self.timer        = Timer.new(options)
      self.projector    = Projector
                          .from_type(options[:projector][:type])
                          .new(options[:projector])
      self.progressable = Progress.new(options)

      options = options.merge(progress: progressable,
                              projector:,
                              timer:)

      self.percentage_component = Components::Percentage.new(options)
      self.rate_component       = Components::Rate.new(options)
      self.time_component       = Components::Time.new(options)

      start at: options[:starting_at] if autostart
    end

    def start(options = {})
      timer.start
      update_progress(:start, options)
    end

    def finish
      return if finished?

      output.with_refresh do
        self.finished = true
        progressable.finish
        timer.stop
      end
    end

    def pause
      output.with_refresh { timer.pause } unless paused?
    end

    def stop
      output.with_refresh { timer.stop } unless stopped?
    end

    def resume
      output.with_refresh { timer.resume } if stopped?
    end

    def reset
      output.with_refresh do
        self.finished = false
        progressable.reset
        projector.reset
        timer.reset
      end
    end

    def stopped?
      timer.stopped? || finished?
    end

    alias paused? stopped?

    def finished?
      finished || (autofinish && progressable.finished?)
    end

    def started? # rubocop:disable Rails/Delegate
      timer.started?
    end

    def decrement
      update_progress(:decrement)
    end

    def increment
      update_progress(:increment)
    end

    def progress=(new_progress)
      update_progress(:progress=, new_progress)
    end

    def total=(new_total)
      update_progress(:total=, new_total)
    end

    def inspect
      "#<ProgressBar:#{progress}/#{total || 'unknown'}>"
    end

    attr_accessor :percentage_component,
                  :rate_component,
                  :time_component

    protected

    attr_accessor :autofinish,
                  :autostart,
                  :finished,
                  :progressable,
                  :projector,
                  :timer

    def update_progress(*)
      progressable.__send__(*)
      projector.__send__(*)
      timer.stop if finished?
    end
  end
end
