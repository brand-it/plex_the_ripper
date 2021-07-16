# frozen_string_literal: true

module MkvInstaller
  class Base
    include Shell
    DOWNLOAD_URI = URI('http://www.makemkv.com/download/')
    VERSION_PATTERN = /.*_v(\d*\.\d*\.\d*)/.freeze

    private

    def files
      return @files if @files

      @files = download_paths.map do |path|
        download(path)
      end
    end

    def download(path)
      conn = Faraday.new(url: DOWNLOAD_URI)
      temp_file(path).tap do |file|
        conn.get(path) do |req|
          req.options.on_data = proc do |chunk, overall_received_bytes|
            Rails.logger.debug { "#{path} Received #{overall_received_bytes} characters" }
            file.write chunk
          end
        end
        file.close
      end
    end

    def temp_file(url)
      Tempfile.new([OS.host_os, File.extname(url)], binmode: true)
    end

    def files_unlink
      files.each(&:unlink)
    end

    def download_paths
      raise 'Child class need to define download_paths'
    end

    def version
      @version ||= request.body.scan(VERSION_PATTERN).flatten.max
    end

    def request
      @request ||= Faraday.get(DOWNLOAD_URI)
    end
  end
end
