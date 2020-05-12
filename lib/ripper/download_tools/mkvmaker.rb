module Downloadtools
  class MKVmaker
    VERSION = '1.15.1'.freeze
    URI = URI("https://www.makemkv.com/download/makemkv_v#{VERSION}_osx.dmg")
    DMG_PATH = "#{APP_ROOT}/apps/makemkv_v#{VERSION}.dmg"

    def progress_bar(total = nil)
      @progress_bar ||= Ripper::ProgressBar.create(
        total: total, title: "Downloading MKVmaker version #{VERSION}"
      )
    end

    def start
      Net::HTTP.start(URI.host, URI.port, use_ssl: (URI.scheme == 'https')) do |http|
        request = Net::HTTP::Get.new URI
        http.request request do |response|
          progress_bar(response.content_length)
          File.open  DMG_PATH, 'w' do |io|
            response.read_body do |chunk|
              io.write chunk
              progress_bar.progress += chunk.length
            end
          end
        end
      end
      progress_bar.finish
    end

    def mount_dmg
      Logger.info('Mounting the DMG file on your mac')
      output = `hdiutil attach #{DMG_PATH}`

      @disk_location = output.scan(/^.*\/Volumes\/makemkv_v#{VERSION}/).first.split("\t").first
    end

    def move_mounted_file
      mounted_app = "/Volumes/makemkv_v#{VERSION}/MakeMKV.app"
      application_dir = "/Applications/MakeMKV.app"
      if File.exist?(application_dir)
        overwrite = TTY::Prompt.new.yes?(
          'MakeMKV.app is already present in you Applications folder. Do you want to overwrite?'
        )
        FileUtils.rm_rf(application_dir)
      end
      FileUtils.cp_r(mounted_app, application_dir) unless File.exist?(application_dir)
    end

    def unmount
      Shell.system!("hdiutil detach #{@disk_location}")
    end

    class << self
      # TODO: Need to add support for windows download as well
      def download
        return if File.exist?(DMG_PATH) && File.exists?(Config.configuration.makemkvcon_path)

        mkv = new
        mkv.start
        mkv.mount_dmg
        mkv.move_mounted_file
        mkv.unmount
      end
    end
  end
end
