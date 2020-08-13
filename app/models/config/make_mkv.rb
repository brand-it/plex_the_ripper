# frozen_string_literal: true

class Config
  class MakeMkv < Config
    settings_defaults(
      disc_source: ENV['MAKE_MKV_DISC_SOURCE'],
      makemkvcon_path: ENV['MAKE_MKV_CON_PATH']
    )

    validate :makemkvcon_path_executable

    def info_command
      [
        settings.makemkvcon_path,
        'info',
        settings.disc_source,
        '-r'
      ].join(' ')
    end

    private

    def makemkvcon_path_executable
      return if File.executable?(settings.makemkvcon_path)

      errors.add(:base, "#{settings.makemkvcon_path} is not an executable")
    end
  end
end
