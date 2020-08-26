# frozen_string_literal: true

class ListDrivesService
  extend Dry::Initializer
  include Shell
  include MkvParser

  option :config_make_mkv, Types.Instance(Config::MakeMkv), default: -> { Config::MakeMkv.newest.first }

  def call
    drives.find { |d| d.drive_name.present? }
  end

  private

  def makemkvcon_path
    config_make_mkv.settings.makemkvcon_path
  end

  def info
    @info ||= system!("#{makemkvcon_path} -r --cache=1 info disc:9999")
  end

  def drives
    @drives ||= parse_mkv_string(info.stdout_str).select { |i| i.is_a?(MkvParser::DRV) }
  end
end
