# frozen_string_literal: true

module Shell
  class Error < StandardError; end
  MAKEMKVCON_WAIT = 10.seconds
  MOUNT_LINE = %r{\A(?<disk_name>\S+)\son\s(?:/Volumes/|)(?<name>.*)\s[(]}
  Device = Struct.new(:drive_name, :disc_name) do
    def rdisk_name
      disc_name.gsub('/dev/', '/dev/r')
    end

    def optical?
      @disc_info ||= `diskutil info #{disc_name}`.strip.downcase
      @disc_info.include?('optical') ||
        @disc_info.include?('cd-rom') ||
        @disc_info.include?('dvd-rom') ||
        @disc_info.include?('blu-ray')
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
    @devices ||= capture3('mount').stdout_str.each_line.filter_map do |line|
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
    while process_running?('makemkvcon')
      @started_waiting ||= Time.current + MAKEMKVCON_WAIT
      kill_process('makemkvcon') unless @started_waiting.future?
      sleep 1
    end
    system!([makemkvcon_path, *cmd].join(' '))
  end

  def process_running?(process_name)
    output = if OS.mac? || OS.linux?
               capture3("ps aux | grep #{process_name} | grep -v grep").stdout_str
             elsif OS.windows?
               capture3("tasklist | findstr #{process_name}").stdout_str
             else
               raise Error, 'Unsupported OS'
             end
    !output.empty?
  end

  def kill_process(name)
    pid = find_process_id(name)
    return if pid.to_i.zero?

    `kill -9 #{pid}`
  end

  def find_process_id(process_name)
    result = `ps aux | grep #{process_name} | grep -v grep`
    result.split("\n").map do |line|
      line.split[1] # PID is the second element in the line
    end
  end

  def system!(*cmd)
    response = capture3(*cmd)
    raise Error, "#{cmd} - #{response.stderr_str}" unless response.status.success?

    Rails.logger.debug { "#{cmd}\n#{response}" }
    response
  end

  def list_drives(no_scan = false)
    makemkvcon(
      ['-r','--cache=1',('--noscan' if noscan), 'info', 'disc:9999'].compact.join(' ')
    ).parsed_mkv.select do |i|
      i.is_a?(MkvParser::DRV) && i.enabled.to_i.positive?
    end
  end
end
