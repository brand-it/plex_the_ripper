# frozen_string_literal: true

namespace :upload do
  desc 'Upload all files that have been ripped correctly but never made it to the FTP server'
  task all: :environment do
    Video.find_each do |video|
      print "Checking Uploading #{video.title} ... "
      next puts 'skip' unless video.tmp_plex_path_exists?

      puts 'uploading'

      progress_bar = ProgressBar.create(
        progress_mark: ' ',
        remainder_mark: "\u{FF65}",
        format: "%e %b\u{15E7}%i %P%% %t",
        title: "Uploading #{video.title}",
        total: video.disk_title.size
      )

      progress_listener = ->(chunk_size: 0) { progress_bar.progress += chunk_size }
      Ftp::UploadMkvService.call(
        disk_title: video.disk_title,
        progress_listener: progress_listener
      )
    end
  end
end
