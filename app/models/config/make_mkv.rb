# frozen_string_literal: true

class Config
  class MakeMkv < Config
    if OS.mac?
      settings_defaults(
        makemkvcon_path: File.join(%w[/ Applications MakeMKV.app Contents MacOS makemkvcon])
      )
    else
      settings_defaults(makemkvcon_path: nil)
    end

    validate :makemkvcon_path_executable

    private

    def makemkvcon_path_executable
      return if File.executable?(settings.makemkvcon_path)

      errors.add(:settings, "makemkvcon path #{settings.makemkvcon_path} is not an executable")
    end
  end
end
