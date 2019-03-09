# frozen_string_literal: true

class CreateMKV
  class << self
    def disc_info
      check_if_mkv_exists
      response = Shell.capture3(disk_info_command)

      return response.stdout_str if response.status.success?

      raise_message_error(response.stdout_str)
    end

    def check_if_mkv_exists
      return if File.executable?(Config.configuration.makemkvcon_path)

      raise(
        Ripper::Terminate,
        'Please download the latest version of Make MKV at http://www.makemkv.com/download/'
      )
    end

    def disk_info_command
      [
        Config.configuration.makemkvcon_path,
        'info',
        Config.configuration.disk_source,
        "--minlength=#{Config.configuration.minlength}",
        '-r'
      ].join(' ')
    end

    def raise_message_error(stdout_str)
      messages = stdout_str.split("\n").select { |m| m =~ /^MSG/ }

      messages = messages.map do |message|
        message_array = message.split(',')
        message_array[message_array.length - 3].delete('"').delete('\\')
      end
      raise Ripper::Terminate, messages.join("\n")
    end
  end
end
