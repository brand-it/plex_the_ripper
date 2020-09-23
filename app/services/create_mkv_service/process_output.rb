# frozen_string_literal: true

class CreateMkvService
  class ProcessOutput
    include MkvParser
    extend Dry::Initializer
    UPDATE_RATE_LIMIT = 1.second

    param :std_out_err
    param :video
    param :disk_title, Types.Instance(DiskTitle)

    def gets # rubocop:disable Metrics/MethodLength
      Thread.new do
        lines = ''
        last_update = Time.current
        while line = std_out_err.gets
          Rails.logger.debug("Process Output #{line.strip}")
          lines += line
          next if (Time.current - last_update) <= UPDATE_RATE_LIMIT

          Thread.new { update_progress(lines) }.join
          last_update = Time.current
          lines       = ''
        end
        update_progress(lines)
      end.join
    end

    def update_progress(lines)
      parse_mkv_string(lines).each do |progress|
        case progress
        when MkvParser::MSG
        when MkvParser::PRGV
          mkv_progress&.assign_attributes(percentage: percentage(progress.current, progress.max))
        when MkvParser::PRGC
          mkv_progress&.complete
          mkv_progress(progress.name)
        end
      end
      @mkv_progresses.values.each(&:save!)
    end

    def mkv_progress(progress_name = nil)
      return @mkv_progress unless progress_name

      @mkv_progresses ||= {}
      @mkv_progresses[progress_name] ||= MkvProgress.find_or_create_by!(
        name: progress_name, video: video
      )
      @mkv_progress = @mkv_progresses[progress_name]
    end

    def percentage(current, max)
      return 0 if max.to_f.zero?

      (current.to_f / max.to_f) * 100.0 # rubocop:disable Style/FloatDivision
    end
  end
end
