# frozen_string_literal: true

class Notification

  def self.send(title, message, message_color: 'blue', event_name: nil)
    ifttt(value1: title, value2: message, event_name: event_name)
    slack(title, message, message_color: message_color)
  rescue StandardError => exception
    Logger.warning(exception.message)
    Logger.debug(title)
    Logger.debug(message)
    Logger.debug(exception.backtrace.join("\n"))
  end

  def self.slack(title, message, message_color: 'blue')
    return if Config.configuration.slack_url.nil?

    Slack::Notifier.new(Config.configuration.slack_url).post(
      attachments: [{
        color: color_to_hex(message_color),
        title: title,
        text: message
      }]
    )
  end


  def self.ifttt(values = {})
    return if Config.configuration.ifttt_webhook_key.nil?

    event_name = values.delete(:event_name)
    url = "https://maker.ifttt.com/trigger/#{event_name || 'plex_the_ripper'}"\
    "/with/key/#{Config.configuration.ifttt_webhook_key}"
    HTTParty.post(
      url,
      body: values.reject { |_k, v| v.nil? }.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )
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
