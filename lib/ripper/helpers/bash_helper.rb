# This is some top level systems for creating bash scripts in ruby
require 'pathname'
require 'optparse'
require 'open3'
require 'timeout'
require 'shellwords'

Open3::Response = Struct.new(:stdout_str, :stderr_str, :status, :cmd)
class BashError < StandardError; end
module BashHelper
  def escape_path(path)
    path.gsub(/ /, '\ ')
  end

  def capture3(*cmd)
    Logger.debug(cmd)
    stdout_str, stderr_str, status = Open3.capture3(*cmd)
    Logger.debug("Command finished #{stdout_str}, #{stderr_str}, #{status}")
    Open3::Response.new(stdout_str, stderr_str, status, *cmd)
  end

  def system!(*cmd)
    response = capture3(*cmd)
    raise BashError, "#{cmd} - #{response.stderr_str}" unless response.status.success?

    response
  end

  def show_wait_spinner(message)
    chars = %w[| / - \\]
    # delay = 1.0 / fps
    still_waiting = true
    index = 0
    while still_waiting == true

      begin
        started_at = Time.now
        Timeout.timeout(300) do
          still_waiting = (yield == true)
        end
        sleep(1) if Time.now < (started_at + 1)
        if still_waiting
          Logger.info "#{message} ... #{chars[(index += 1) % chars.length]}", rewrite: true
        end
      rescue Timeout::Error => exception
        Logger.error "Timeout happened #{exception.message}"
      end
    end
  end

  def ask(question, type: String)
    print(question)
    answer = STDIN.gets.strip # if you don't use STDIN it will pull from ARGS depending on the situation
    Logger.debug("answer: #{answer}")
    return if answer == '' || answer.nil?
    return answer.to_i if type == Integer
    return answer.to_f if type == Float
    return answer =~ /\Ay/i || answer == '1' if type == TrueClass
    return answer =~ /\An/i || answer == '0' if type == FalseClass

    answer.to_s
  end

  def ask_value_required(question = nil, type: String, default: nil)
    answer = nil
    while answer.nil?
      yield if block_given?
      answer = ask(question, type: type)
      answer = default if answer.to_s == ''
    end
    answer
  end
end
