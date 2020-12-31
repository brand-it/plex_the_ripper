# frozen_string_literal: true

module MkvDownloader
  class Posix < Base
    private

    def download_paths
      [
        "makemkv-bin-#{version}.tar.gz",
        "makemkv-oss-#{version}.tar.gz"
      ]
    end
  end
end
