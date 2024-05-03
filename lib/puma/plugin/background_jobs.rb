Puma::Plugin.create do
  def start(launcher)
    2.times.each do
      in_background do
        loop do
          break if launcher.instance_variable_get(:@status) != :run

          Rails.logger.info 'Processing work...'
          ApplicationWorker.process_work
          sleep 5
        end
      end
    end

    in_background do
      loop do
        begin
          Rails.logger.info 'Checking for new movies...'
          Movie.find_each do |movie|
            next unless movie.tmp_plex_path_exists?

            Rails.logger.info "Uploading #{movie.title}..."
            UploadWorker.perform_async(disk_title_id: movie.disk_title_id)
          end
          Rails.logger.info 'Scanning Plex...'
          last_sync = Video.maximum(:synced_on)

          synced_recently = last_sync.present? && (last_sync + 5.minutes > Time.zone.now)
          ScanPlexWorker.perform_async if Video.none? || !synced_recently
        rescue StandardError => e
          Rails.logger.error e.message
          Rails.logger.error e.backtrace.join("\n")
        end
        sleep 10
      end
    end
  end
end
