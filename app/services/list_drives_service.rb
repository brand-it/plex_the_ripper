# frozen_string_literal: true

class ListDrivesService
  include Shell
  extend Dry::Initializer
  DRIVE = 'DRV'
  class Drive
    extend Dry::Initializer
    param :index, Types::Coercible::Integer
    param :visible, Types::Coercible::Integer
    param :enabled, Types::Coercible::Integer
    param :flags, Types::Coercible::String
    param :drive_name, Types::Coercible::String
    param :disk_name, Types::Coercible::String
  end

  param :make_mkv, Types.Instance(Config::MakeMkv), default: -> { Config::MakeMkv.newest.first }

  def call
    drives.find{ |d| d.drive_name.present? }
  end

  def makemkvcon_path
    make_mkv.settings.makemkvcon_path
  end

  def info
    @info ||= system!("#{makemkvcon_path} -r --cache=1 info disc:9999")
  end

  def drives
    @drives ||= info.stdout_str.lines.select { |x| x.starts_with?(DRIVE) }.map do |c|
      Drive.new(*c.strip.split(',').map { |r| r.delete('"') }[1..])
    end
  end
end
