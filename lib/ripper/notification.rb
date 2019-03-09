# frozen_string_literal: true

class Notification
  def self.send_text(message)
    auth_token = '5e695829e7cfcd79d45c3b437354c463'
    user_id = 'AC9af401e21f31056f078a1dbc59b59852'
    params = [
      '-X POST',
      "--data-urlencode 'To=+12105353532'",
      "--data-urlencode 'From=+15592060364'",
      "--data-urlencode 'Body=#{message}'",
      "-u #{user_id}:#{auth_token}"
    ]
    Shell.system!(
      "curl 'https://api.twilio.com/2010-04-01/"\
      "Accounts/#{user_id}/Messages.json'"\
      " #{params.join(' ')}"
    )
  end

  def self.slack(title, message, message_color: 'blue')
    Slack::Notifier.new(
      'https://hooks.slack.com/services/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'
    ).post(
      attachments: [{
        color: color_to_hex(message_color),
        title: title,
        text: message
      }]
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
