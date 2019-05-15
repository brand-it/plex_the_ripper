class CreateMKV
  module Progressable
    def set_progress_total(total)
      return if total == progressbar.total
      Logger.debug("Updating total to #{total} from #{progressbar.total}")
      progressbar.total = total
    end

    def increment_progress(total)
      total = progressbar.total if total.to_i > progressbar.total.to_i
      progressbar.progress += (total - progressbar.progress)
    end

    def reset_progress(current_title)
      return if progressbar.title == current_title

      progressbar.finish
      progressbar.reset
      progressbar.title = current_title
      progressbar.start
      progressbar
    end

    def notify_slack_of_progress
      return if notification_percentages.empty?
      return if notification_percentages.first > progressbar.to_h['percentage']

      notification_percentages.shift

      Notification.slack(
        "Progress Update #{Config.configuration.video_name}",
        progressbar.to_s,
        message_color: 'green'
      )
    end

    def progress_done
      progressbar.finish
    end

    def process_progress_from(raw_line)
      line = raw_line.strip
      Logger.debug(line)
      parsed = parse_mkv_info(line)

      case parsed[:type]
      when 'PRGV'
        set_progress_total(parsed[:progress][:max])
        increment_progress(parsed[:progress][:total])
      when 'PRGC'
        reset_progress(parsed[:progress_title][:name])
      end
    end

    def parse_mkv_info(line)
      parsed = {}
      type, values = line.split(':')
      parsed[:type] = type
      parse_prgv!(parsed, values)
      parse_prgc!(parsed, values)
      parsed
    end

    # Progress bar values for current and total progress
    # PRGV:current,total,max
    # current - current progress value
    # total - total progress value
    # max - maximum possible value for a progress bar, constant
    def parse_prgv!(parsed_hash, line)
      return if parsed_hash[:type] != 'PRGV'

      parsed_hash[:progress] = {}
      current, total, max = line.split(',').map(&:to_i)
      parsed_hash[:progress][:current] = current
      parsed_hash[:progress][:total] = total
      parsed_hash[:progress][:max] = max
      parsed_hash
    end

    # Current and total progress title
    # PRGC:code,id,name
    # PRGT:code,id,name
    # code - unique message code
    # id - operation sub-id
    # name - name string
    def parse_prgc!(parsed_hash, line)
      return if parsed_hash[:type] != 'PRGC'

      parsed_hash[:progress_title] = {}
      code, id, name = line.split(',')
      parsed_hash[:progress_title][:code] = code
      parsed_hash[:progress_title][:id] = id
      parsed_hash[:progress_title][:name] = name.strip.delete('"')
      parsed_hash
    end
  end
end
