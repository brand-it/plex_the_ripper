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
    setting :makemkvcon_path, default: -> { default_makemkvcon_path }

    validates :settings_makemkvcon_path, presence: true
    validate :makemkvcon_path_executable

    def self.current
      newest.first || raise(ActiveRecord::RecordNotFound, 'Could not find current Config::MakeMkv')
    end

    private

    def default_makemkvcon_path
      if OS.mac?
        `locate makemkvcon`
      elsif OS.posix?
        '/usr/bin/makemkv/makemkvcon'
      end
    end

    def makemkvcon_path_executable
      return if File.executable?(settings.makemkvcon_path.to_s)

      errors.add(:settings_makemkvcon_path, 'is required to be an executable')
    end
  end
end
