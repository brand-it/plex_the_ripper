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
    if OS.mac?
      settings_defaults(
        makemkvcon_path: File.join(%w[/ Applications MakeMKV.app Contents MacOS makemkvcon])
      )
    else
      settings_defaults(makemkvcon_path: nil)
    end

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
  end
end
