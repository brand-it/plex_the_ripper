# frozen_string_literal: true

namespace :upload do
  desc 'Upload all files that have been ripped correctly but never made it to the FTP server'
  task all: :environment do
    Video.all.find_each do |video|
      print "Checking Uploading #{video.title} ... "
      next puts 'skip' unless video.tmp_plex_path_exists?

      puts 'uploading'

      progress_bar = ProgressBar.create(
        title: "Uploading #{video.title} to #{video.plex_path}",
        total: video.disk_title.size,
        format: '%t %a %e %P% Processed: %c from %C'
      )

      progress_listener = ->(chunk_size: 0) { progress_bar.progress += chunk_size }
      Ftp::UploadMkvService.call(
        disk_title: video.disk_title,
        progress_listener: progress_listener
      )
    end
  end
end
