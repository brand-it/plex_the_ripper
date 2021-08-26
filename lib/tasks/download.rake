# frozen_string_literal: true

namespace :download do
  desc 'Download Optimized Movies from Plex Using FTP'
  task :optimized, [:directory] => :environment do |_task, args|
    Movie.with_video_blobs_optimized.order(popularity: :desc).each do |movie|
      video_blob = movie.video_blobs.first

      next puts "Missing Checksum for #{video_blob.key}" unless video_blob.checksum

      track_progress = ProgressBar.create(
        title: "Downloading #{movie.plex_name} as #{video_blob.content_type}",
        total: video_blob.byte_size,
        starting_at: File.size?("#{args[:directory]}/#{video_blob.filename}"),
        format: '%t %a %e %P% Processed: %c from %C'
      )
      listener = ->(_video_blob, chunk_size) { track_progress.progress += chunk_size }
      result = Ftp::Download.new(
        video_blob: video_blob,
        directory: args[:directory],
        progress_listener: listener,
        max_retries: 50
      ).call
      track_progress.finish

      puts 'Download status'
      puts "  completed_at: #{result.progress.completed_at}"
      puts "  failed_at: #{result.progress.failed_at}"
      puts "  progress_key: #{result.progress.key}"
      puts "  context_type: #{video_blob.content_type}"
      puts "  video_blob_key: #{video_blob.key}"
      if result.progress.message.present?
        puts 'Message'
        puts progress.message
      end
      puts "\n\n"
    end
  end

  desc 'Generate Checksums'
  task generate_checksums: :environment do
    VideoBlob.all.where(checksum: nil).find_each do |video_blob|
      track_progress = ProgressBar.create(
        title: "Downloading '#{video_blob.filename}' as #{video_blob.content_type}",
        total: video_blob.byte_size,
        format: '%t %a %e %P% Processed: %c from %C'
      )
      progress_listener = ->(chunk_size: 0) { track_progress.progress += chunk_size }
      download_finished_listener = lambda do |result: nil|
        track_progress.finish
        if result.success?
          puts "Finished downloading '#{video_blob.filename}'"
        else
          puts "Failed to download '#{video_blob.filename}"
        end
      end

      VideoBlobChecksumService.new(
        video_blob: video_blob,
        progress_listener: progress_listener,
        download_finished_listener: download_finished_listener
      ).call

      puts "Generated checksum #{video_blob.checksum}"
    end
  end
end
