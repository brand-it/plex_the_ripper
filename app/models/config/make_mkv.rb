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
    settings makemkvcon_path: DEFAULT_MAKEMKVCON_PATH

    validates :settings_makemkvcon_path, presence: true
    validate :makemkvcon_path_executable

    def self.current
      newest.first || raise(ActiveRecord::RecordNotFound, 'Could not find current Config::MakeMkv')
    end

    private

    def makemkvcon_path_executable
      return if settings.makemkvcon_path.blank?
      return if File.executable?(settings.makemkvcon_path)

      errors.add(:settings_makemkvcon_path, 'is required to be an executable')
    end
  end
end
