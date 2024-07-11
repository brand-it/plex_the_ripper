# frozen_string_literal: true

module Shell
  class Error < StandardError; end
  MOUNT_LINE = %r{\A(?<disk_name>\S+)\son\s(?:/Volumes/|)(?<name>.*)\s[(]}
  Device = Struct.new(:name, :disk_name) do
    def rdisk_name
      disk_name.gsub('/dev/', '/dev/r')
    end

    def optical?
      @disk_info ||= `diskutil info #{disk_name}`.strip.downcase
      @disk_info.include?('optical') ||
        @disk_info.include?('cd-rom') ||
        @disk_info.include?('dvd-rom') ||
        @disk_info.include?('blu-ray')
    end
  end

  Standard = Struct.new(:stdout_str, :stderr_str, :status, keyword_init: true) do
    include MkvParser

    delegate :success?, to: :status

    def parsed_mkv
      @parsed_mkv ||= parse_mkv_string(stdout_str)
    end
  end

  def devices
    @devices ||= `mount`.each_line.filter_map do |line|
      next unless line.start_with?('/dev/')

      match = line.match(MOUNT_LINE)
      Device.new(match[:name], match[:disk_name])
    end
  end

  def capture3(*cmd)
    Rails.logger.debug { "command: #{cmd.join(', ')}" }
    stdout_str, stderr_str, status = Open3.capture3(*cmd)
    Rails.logger.debug { "\n#{stdout_str}\n#{stderr_str}\n#{status}" }
    Standard.new(stdout_str:, stderr_str:, status:)
  end

  def makemkvcon(*cmd)
    makemkvcon_path = Config::MakeMkv.newest.settings.makemkvcon_path
    sleep 1 while process_running?('makemkvcon')
    system!([makemkvcon_path, *cmd].join(' '))
  end

  def process_running?(process_name)
    output = if OS.mac? || OS.linux?
               `ps aux | grep #{process_name} | grep -v grep`
             elsif OS.windows?
               `tasklist | findstr #{process_name}`
             else
               raise Error, 'Unsupported OS'
             end
    !output.empty?
  end

  def system!(*cmd)
    response = capture3(*cmd)
    raise Error, "#{cmd} - #{response.stderr_str}" unless response.status.success?

    Rails.logger.debug { "#{cmd}\n#{response}" }
    response
  end
end
