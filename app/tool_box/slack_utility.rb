# frozen_string_literal: true

module SlackUtility
  def notify_slack(text)
    return if ::Config::Slack.newest.settings_webhook_url.nil?

    notifier = ::Slack::Notifier.new ::Config::Slack.newest.settings_webhook_url,
                                     channel: ::Config::Slack.newest.settings_channel
    notifier.post text:
  end
end
