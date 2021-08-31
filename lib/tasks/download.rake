# frozen_string_literal: true

namespace :download do
  desc 'Download Optimized Movies from Plex Using FTP'
  task :optimized, %i[directory force_verify] => :environment do |_task, args|
    Movie.optimized_with_checksum.order(popularity: :desc).each do |movie|
      video_blob = movie.optimized_video_blobs.first

      progress = video_blob.progresses.find_or_create_by key: args[:directory],
                                                         descriptive: :download_ftp

      next puts "Already Downloaded Successfully #{video_blob.key}" if progress.completed? && args[:force_verify].blank?

      checksum_track_progress = ProgressBar.create(
        title: "Verifying Checksum #{movie.plex_name} as #{video_blob.content_type}",
        total: video_blob.byte_size,
        format: '%t %a %e %P% Processed: %c from %C'
      )
      track_progress = ProgressBar.create(
        title: "Downloading #{movie.plex_name} as #{video_blob.content_type}",
        total: video_blob.byte_size,
        format: '%t %a %e %P% Processed: %c from %C'
      )

      listener = ->(chunk_size: 0) { track_progress.progress += chunk_size }
      checksum_listener = ->(chunk_size: 0) { checksum_track_progress.progress += chunk_size }

      result = Ftp::Download.call(
        video_blob: video_blob,
        destination_directory: args[:directory],
        download_progress_listener: listener,
        checksum_progress_listener: checksum_listener,
        max_retries: 50
      )
      track_progress.finish
      checksum_track_progress.finish
      result.success? ? progress.complete : progress.fail(result.failure_message)
      progress.save!

      puts 'Download status'
      puts "  completed_at: #{progress.completed_at}"
      puts "  failed_at: #{progress.failed_at}"
      puts "  progress_key: #{progress.key}"
      puts "  context_type: #{video_blob.content_type}"
      puts "  video_blob_key: #{video_blob.key}"
      if progress.message.present?
        puts 'Message'
        puts progress.message
      end

      next if result.success?

      puts "Destroying #{result.destination_path}"
      FileUtils.rm_rf result.destination_path
      puts "Retrying to download #{movie.plex_name} as #{video_blob.content_type}"
      redo
    end
  end

  desc 'Generate Checksums'
  task generate_checksums: :environment do
    VideoBlob.missing_checksum.find_each do |video_blob|
      track_progress = ProgressBar.create(
        title: "Downloading #{video_blob.filename} as #{video_blob.content_type}",
        total: video_blob.byte_size,
        format: '%t %a %e %P% Processed: %c from %C'
      )
      checksum_track_progress = ProgressBar.create(
        title: "Verifying Checksum #{video_blob.filename} as #{video_blob.content_type}",
        total: video_blob.byte_size,
        format: '%t %a %e %P% Processed: %c from %C'
      )
      listener = ->(chunk_size: 0) { track_progress.progress += chunk_size }
      checksum_listener = ->(chunk_size: 0) { checksum_track_progress.progress += chunk_size }

      VideoBlobChecksumService.new(
        video_blob: video_blob,
        download_progress_listener: listener,
        checksum_progress_listener: checksum_listener
      ).call

      puts "Generated checksum #{video_blob.checksum}"
      puts "Total Finished: #{VideoBlob.where.not(checksum: nil).count}"
      puts "Total Remaining: #{VideoBlob.where(checksum: nil).count}"
    end
  end
end
