# frozen_string_literal: true

class CreateMkvService
  class ProcessOutput
    include MkvParser
    extend Dry::Initializer

    param :std_out_err
    param :video

    def gets
      while line = std_out_err.gets
        update_progress(line)
      end
    end

    def update_progress(line)
      parse_mkv_string(line).each do |progress|
        Rails.logger.debug(progress)
        case progress
        when MkvParser::PRGV
          mkv_progress.update!(percentage: progress.current.to_f)
        when MkvParser::PRGC, MkvParser::PRGT
          mkv_progress&.complete!
          mkv_progress(progress)
        end
      end
    end

    def mkv_progress(progress = nil)
      return @mkv_progress if progress.nil?

      @mkv_progress = MkvProgress.find_or_initialize_by(name: progress.name, video: video)
    end
  end
end
