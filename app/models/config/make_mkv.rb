# frozen_string_literal: true

class Config
  class MakeMkv < Config
    settings_defaults(
      disk_source: ENV['MAKE_MKV_DISK_SOURCE'],
      makemkvcon_path: ENV['MAKE_MKV_CON_PATH']
    )

    validate :makemkvcon_path_executable
    validate :disk_source_exists

    def info_command
      [
        settings.makemkvcon_path,
        'info',
        settings.disk_source,
        '-r'
      ].join(' ')
    end

    private

    def disk_source_exists
      return if File.exist?(settings.disk_source)

      errors.add(:settings, "disk source #{settings.disk_source} does not exist")
    end

    def makemkvcon_path_executable
      return if File.executable?(settings.makemkvcon_path)

      errors.add(:settings, "makemkvcon path #{settings.makemkvcon_path} is not an executable")
    end
  end
end
