# frozen_string_literal: true

# == Schema Information
#
# Table name: configs
#
#  id         :integer          not null, primary key
#  settings   :text
#  type       :string           default("Config"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Config
  class MakeMkv < Config
    DEFAULT_MAKEMKVCON_PATH = if OS.mac?
                                '/Applications/MakeMKV.app/Contents/MacOS/makemkvcon'
                              elsif OS.posix?
                                '/usr/bin/makemkv/makemkvcon'
                              end
    settings_defaults(
      makemkvcon_path: DEFAULT_MAKEMKVCON_PATH,
      version: nil
    )

    validate :mkvemkvcon_path_present
    validate :makemkvcon_path_executable

    def self.current
      newest.first || create!
    end

    private

    def makemkvcon_path_executable
      return if settings.makemkvcon_path.blank?
      return if File.executable?(settings.makemkvcon_path)

      errors.add(:settings, "makemkvcon path #{settings.makemkvcon_path} is not an executable")
    end

    def mkvemkvcon_path_present
      return if settings.makemkvcon_path.present?

      errors.add(:settings, 'makemkvcon path is required')
    end
  end
end
