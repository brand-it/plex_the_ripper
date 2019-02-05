class Logger
  if Config.configuration.log_directory
    LOG_PATH = File.join([Config.configuration.log_directory, 'movies.log'])
    RIP_PATH = File.join([Config.configuration.log_directory, 'rip_info.log'])
  else
    RIP_PATH = nil
    LOG_PATH = nil
  end

  class << self
    def log_rip_time(seconds, movie_name, file_size)
      return unless can_log?

      File.open(Logger::RIP_PATH, 'a') do |file|
        file.write("#{seconds}, #{movie_name}, #{file_size}\n")
      end
    end

    def create_log_file
      return unless can_log?

      FileUtils.mkdir_p(Config.configuration.log_directory)
      FileUtils.touch(Logger::LOG_PATH)
      FileUtils.touch(Logger::RIP_PATH)
    end

    def log(message)
      return unless can_log?

      create_log_file
      text = message.to_s.gsub(/\033.*?m/, '').strip
      return if text == ''

      # File is created if does not exist
      File.open(Logger::LOG_PATH, 'a') do |file|
        file.write("#{text}\n")
      end
    end

    def info(message, rewrite: false)
      log(message)
      if rewrite && !Config.configuration.verbose
        print "#{message}\r"
        $stdout.flush
      else
        puts message
      end
    end

    def debug(message)
      info "\033[0;36m#{message}\033[0m" if Config.configuration.verbose
    end

    def success(message)
      info "\033[1;32m#{message}\033[0m"
    end

    def error(message)
      info "\033[0;31m#{message}\033[0m"
    end

    def warning(message, rewrite: false)
      info "\033[0;33m#{message}\033[0m", rewrite: rewrite
    end

    private

    def can_log?
      Logger::LOG_PATH && Logger::RIP_PATH &&
        File.exist?(Logger::LOG_PATH) && File.exist?(Logger::RIP_PATH)
    end
  end
end
