# frozen_string_literal: true

class Notification
  def self.slack(title, message, message_color: 'blue')
    return if Config.configuration.slack_url.nil?

    Slack::Notifier.new(Config.configuration.slack_url).post(
      attachments: [{
        color: color_to_hex(message_color),
        title: title,
        text: message
      }]
    )
  rescue StandardError => exception
    Logger.warn("Failed to notify slack using #{Config.configuration.slack_url}")
    Logger.warn(exception.message)
    Logger.debug(title)
    Logger.debug(message)
    Logger.debug(exception.backtrace.join("\n"))
  end

  def self.color_to_hex(color)
    case color
    when 'green'
      '#36a64f'
    when 'yellow'
      '#f4e541'
    when 'red'
      '#f4425c'
    when 'blue', blank?
      '#dbdff9'
    end
  end
end
