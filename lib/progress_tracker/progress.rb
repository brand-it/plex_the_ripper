# frozen_string_literal: true

require 'ruby-progressbar/errors/invalid_progress_error'

module ProgressTracker
  class Progress
    DEFAULT_TOTAL              = 100
    DEFAULT_BEGINNING_POSITION = 0

    attr_reader               :total,
                              :progress
    attr_accessor             :starting_position

    def initialize(options = {})
      self.total = options.fetch(:total, DEFAULT_TOTAL)

      start(at: DEFAULT_BEGINNING_POSITION)
    end

    def start(options = {})
      self.progress =
        self.starting_position = options[:at] || progress
    end

    def finish
      self.progress = total unless unknown?
    end

    def finished?
      @progress == @total
    end

    def increment
      warn "WARNING: Your progress bar is currently at #{progress} out of #{total}" if progress == total

      self.progress += 1 unless progress == total
    end

    def decrement
      warn "WARNING: Your progress bar is currently at #{progress} out of #{total}" if progress.zero?

      self.progress -= 1 unless progress.zero?
    end

    def reset
      start(at: starting_position)
    end

    def progress=(new_progress)
      if total && new_progress > total
        raise ProgressBar::InvalidProgressError,
              "You can't set the item's current value to be greater than the total."
      end

      @progress = new_progress
    end

    def total=(new_total)
      unless progress.nil? || new_total.nil? || new_total >= progress
        raise ProgressBar::InvalidProgressError,
              "You can't set the item's total value to less than the current progress."
      end

      @total = new_total
    end

    def percentage_completed
      return 0   if total.nil?
      return 100 if total.zero?

      # progress / total * 100
      #
      # Doing this way so we can avoid converting each
      # number to a float and then back to an integer.
      #
      (progress * 100 / total).to_i
    end

    def none?
      progress.zero?
    end

    def unknown?
      progress.nil? || total.nil?
    end

    def total_with_unknown_indicator
      total || '??'
    end

    def percentage_completed_with_precision
      return 100.0  if total.zero?
      return 0.0    if total.nil?

      format('%5.2f', (progress * 100 / total.to_f * 100).floor / 100.0)
    end

    def absolute
      progress - starting_position
    end
  end
end
