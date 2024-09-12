# frozen_string_literal: true

module Shell
  class Error < StandardError; end
  include MkvParser
  include Wisper::Publisher

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

  def wait_makemkvcon(*cmd)
    while process_running?('makemkvcon')
      @wait_until ||= Time.current + MAKEMKVCON_WAIT
      broadcast(:mkv_waiting)
      kill_process('makemkvcon') unless @wait_until.future?
      sleep 1
    end
    makemkvcon(*cmd)
  end

  # makemkvcon [options] Command Parameters
  # https://www.makemkv.com/developers/usage.txt
  #
  # General options:
  #
  # --messages=file
  # Output all messages to file. Following special file names are recognized:
  # -stdout - stdout
  # -stderr - stderr
  # -null - disable output
  # Default is stdout
  #
  # --progress=file
  # Output all progress messages to file. The same special file names as in --messages are recognized with additional
  # value "-same" to output to the same file as messages. Naturally --progress should follow --messages in this case.
  # Default is no output.
  #
  # --debug[=file]
  # Enables debug messages and optionally changes the location of debug file. Default: program preferences.
  #
  # --directio=true/false
  # Enables or disables direct disc access. Default: program preferences.
  #
  # --noscan
  # Don't access any media during disc scan and do not check for media insertion and removal. Helpful when other
  # applications already accessing discs in other drives.
  #
  # --cache=size
  # Specifies size of read cache in megabytes used by MakeMKV. By default program uses huge amount of memory. About 128
  # MB is recommended for streaming and backup, 512MB for DVD conversion and 1024MB for Blu-ray conversion.
  #
  # Streaming options:
  #
  # --upnp=true/false
  # Enable or disable UPNP streaming. Default: program preferences.
  #
  # --bindip=address string
  # Specify IP address to bind. Default: None, UPNP server binds to the first available address and web
  # server listens on all available addresses.
  #
  # --bindport=port
  # Specify web server port to bind. Default: 51000.
  #
  # Backup options:
  #
  # --decrypt
  # Decrypt stream files during backup. Default: no decryption.
  #
  # Conversion options:
  #
  # --minlength=seconds
  # Specify minimum title length. Default: program preferences.
  #
  # Automation options.
  #
  # -r , --robot
  # Enables automation mode. Program will output more information in a format that is easier to parse. All output is
  # line-based and output is flushed on line end. All strings are quoted, all control characters and quotes are
  # backlash-escaped. If you automate this program it is highly recommended to use this option. Some options make
  # reference to apdefs.h file that can be found in MakeMKV open-source package, included with version for Linux.
  # These values will not change in future versions.
  #
  # Message formats:
  #
  # Message output
  # MSG:code,flags,count,message,format,param0,param1,...
  # code - unique message code, should be used to identify particular string in language-neutral way.
  # flags - message flags, see AP_UIMSG_xxx flags in apdefs.h
  # count - number of parameters
  # message - raw message string suitable for output
  # format - format string used for message. This string is localized and subject to change, unlike message code.
  # paramX - parameter for message
  #
  # Current and total progress title
  # PRGC:code,id,name
  # PRGT:code,id,name
  # code - unique message code
  # id - operation sub-id
  # name - name string
  #
  # Progress bar values for current and total progress
  # PRGV:current,total,max
  # current - current progress value
  # total - total progress value
  # max - maximum possible value for a progress bar, constant
  #
  # Drive scan messages
  # DRV:index,visible,enabled,flags,drive name,disc name
  # index - drive index
  # visible - set to 1 if drive is present
  # enabled - set to 1 if drive is accessible
  # flags - media flags, see AP_DskFsFlagXXX in apdefs.h
  # drive name - drive name string
  # disc name - disc name string
  #
  # Disc information output messages
  # TCOUT:count
  # count - titles count
  #
  # Disc, title and stream information
  # CINFO:id,code,value
  # TINFO:id,code,value
  # SINFO:id,code,value
  #
  # id - attribute id, see AP_ItemAttributeId in apdefs.h
  # code - message code if attribute value is a constant string
  # value - attribute value
  #
  # Examples:
  #
  # Copy all titles from first disc and save as MKV files:
  # makemkvcon mkv disc:0 all c:\folder
  #
  # List all available drives
  # makemkvcon -r --cache=1 info disc:9999
  #
  # Backup first disc decrypting all video files in automation mode with progress output
  # makemkvcon backup --decrypt --cache=16 --noscan -r --progress=-same disc:0 c:\folder
  #
  # Start streaming server with all output suppressed on a specific address and port
  # makemvcon stream --upnp=1 --cache=128 --bindip=192.168.1.102 --bindport=51000 --messages=-none
  def makemkvcon(*cmd)
    makemkvcon_path = Shellwords.escape(Config::MakeMkv.newest.settings.makemkvcon_path)
    out = {
      stdout: [],
      stderr: []
    }
    Open3.popen3([makemkvcon_path, *cmd].join(' ')) do |stdin, stdout_str, stderr_str, wait_thr|
      stdin.close
      [[stdout_str, :stdout], [stderr_str, :stderr]].each do |std, type|
        while (raw_line = std.gets)
          begin
            out[type] << raw_line
            broadcast(:mkv_raw_line, parse_mkv_string(raw_line).first)
          rescue StandardError => e
            Rails.logger.error { "Error parsing mkv string: #{e.message}" }
            Rails.logger.error { e.backtrace.join("\n") }
          end
        end
      end
      Standard.new(
        stdout_str: out[:stdout].compact_blank.join,
        stderr_str: out[:stderr].compact_blank.join,
        status: wait_thr.value
      )
    end
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

    Rails.logger.warn("Killing process #{name} - #{pid}")
    `kill -9 #{pid}`
  end

  def find_process_id(process_name)
    result = `ps aux | grep #{process_name} | grep -v grep`
    result.split("\n").map do |line|
      line.split[1] # PID is the second element in the line
    end.first
  end

  def system!(*cmd)
    response = capture3(*cmd)
    raise Error, "#{cmd} - #{response.stderr_str}" unless response.status.success?

    Rails.logger.debug { "#{cmd}\n#{response}" }
    response
  end

  def list_drives(noscan: false)
    wait_makemkvcon(
      ['-r', '--cache=1', ('--noscan' if noscan), 'info', 'disc:9999'].compact.join(' ')
    ).parsed_mkv.select do |i|
      i.is_a?(MkvParser::DRV) && i.enabled.to_i.positive?
    end
  end
end
