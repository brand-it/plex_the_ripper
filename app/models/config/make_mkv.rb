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
    setting do |s|
      s.attribute :makemkvcon_path, default: -> { default_makemkvcon_path }
      s.attribute :registration_key
    end

    validates :settings_makemkvcon_path, presence: true
    validates :settings_registration_key, presence: true
    validate :makemkvcon_path_executable

    private

    def makemkvcon_path_executable
      return if File.executable?(settings.makemkvcon_path.to_s)

      errors.add(:settings_makemkvcon_path, 'is required to be an executable')
    end

    def default_makemkvcon_path
      if OS.mac?
        locate_mac_makemkvcon
      elsif OS.posix?
        '/usr/bin/makemkv/makemkvcon_test'
      end
    end

    def locate_mac_makemkvcon
      makeconmkv = '/Applications/MakeMKV.app/Contents/MacOS/makemkvcon'
      return makeconmkv if File.executable?(makeconmkv)

      `locate makemkvcon`.split.find { |f| File.executable? f }
    end
  end
end
