# frozen_string_literal: true

module MkvInstaller
  class Base
    include Shell
    DOWNLOAD_URI = URI('https://www.makemkv.com/download/')
    VERSION_PATTERN = /.*_v(\d*\.\d*\.\d*)/

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
            Rails.logger.info("#{path} Received #{overall_received_bytes} characters")
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
      @version ||= request.body.scan(VERSION_PATTERN).flatten.max.tap do |version|
        raise "Version could not be resolved from #{request.body}" if version.nil?
      end
    end

    def request
      @request ||= Faraday.get(DOWNLOAD_URI).tap do |response|
        raise "Failure to access download url #{DOWNLOAD_URI}" if response.status != 200
      end
    end
  end
end
