# frozen_string_literal: true

class DiskInfoService
  extend Dry::Initializer
  include Shell

  param :config_make_mkv, Types.Instance(Config::MakeMkv)
  option :disk_source, Types::String

  def call
    system!([config_make_mkv.settings.makemkvcon_path, 'info', disk_source, '-r'].join(' '))
  end
end
