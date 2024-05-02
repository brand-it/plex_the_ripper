# frozen_string_literal: true

class ListDrivesService
  extend Dry::Initializer
  include Shell
  include MkvParser

  option :noscan, Types::Bool, default: -> { false }

  class << self
    def results(...)
      new(...).results
    end
  end

  def results
    drives
  end

  private

  def info
    @info ||= makemkvcon(
      [
        '-r',
        '--cache=1',
        ('--noscan' if noscan),
        'info',
        'disc:9999'
      ].compact.join(' ')
    )
  end

  def drives
    @drives ||= info.parsed_mkv.select do |i|
      i.is_a?(MkvParser::DRV) && i.enabled.to_i.positive?
    end
  end
end
