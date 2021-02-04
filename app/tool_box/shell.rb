# frozen_string_literal: true

module Shell
  class Error < StandardError; end

  def capture3(*cmd)
    Rails.logger.debug("command: #{cmd.join(', ')}")
    stdout_str, stderr_str, status = Open3.capture3(*cmd)
    Rails.logger.debug("\n#{stdout_str}\n#{stderr_str}\n#{status}")
    OpenStruct.new(stdout_str: stdout_str, stderr_str: stderr_str, status: status)
  end

  def system!(*cmd)
    response = capture3(*cmd)
    raise Error, "#{cmd} - #{response.stderr_str}" unless response.status.success?

    response
  end
end
