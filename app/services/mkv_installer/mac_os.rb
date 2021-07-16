# frozen_string_literal: true

module MkvInstaller
  class MacOs < Base
    class Error < StandardError; end
    APP_PATH = '/Applications/MakeMKV.app'

    def self.call
      new.call
    end

    def call
      attach
      copy
    ensure
      detach
      files_unlink
    end

    private

    def copy
      FileUtils.rm_rf(APP_PATH)
      FileUtils.cp_r(mounted_app, APP_PATH)
    end

    def attach
      @attach ||= system!("hdiutil attach #{dmg_file.path}")
    end

    def detach
      return unless @attach

      system!("hdiutil detach /Volumes/makemkv_v#{version}")
      @attach = nil
    end

    def mounted_app
      "/Volumes/makemkv_v#{version}/MakeMKV.app"
    end

    def dmg_file
      raise(Error, 'Failed to download or find MKV DMG') if files.first.nil?

      files.first
    end

    def download_paths
      ["makemkv_v#{version}_osx.dmg"]
    end
  end
end
