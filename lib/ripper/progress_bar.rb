# frozen_string_literal: true

module Ripper
  class ProgressBar < ProgressBar
    PROGRESS_BAR_FORMATS = {
      default: '%t %p% %E | Elapsed %a',
      with_bar: '%e |%b>>%i| %p%% %t'
    }.freeze

    class << self
      def create(args = {})
        args[:format] ||= PROGRESS_BAR_FORMATS[:default]
        super(args)
      end
    end
  end
end
