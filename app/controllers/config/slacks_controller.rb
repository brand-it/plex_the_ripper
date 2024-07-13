# frozen_string_literal: true

class Config
  class SlacksController < ApplicationController
    before_action :set_slack, only: %i[edit update]

    def new
      @slack_config = Config::Slack.new
    end

    def edit; end

    def create
      @slack_config = Config::Slack.new(slack_params)

      if @slack_config.save
        notifier = ::Slack::Notifier.new @slack_config.settings_webhook_url,
                                         channel: @slack_config.settings_channel
        notifier.ping 'Hello I will post messages to this channel as they happen'
        redirect_to root_path, notice: 'Slack Config was successfully created.'
      else
        render :new
      end
    end

    def update
      if @config_slack.update(slack_params)
        notifier = ::Slack::Notifier.new @config_slack.settings_webhook_url,
                                         channel: @config_slack.settings_channel

        notifier.ping 'Hello I will post messages to this channel as they happen'

        redirect_to root_path, notice: 'Updated Slack config successfully'
      else
        render :edit
      end
    end

    private

    def set_slack
      @config_slack = Config::Slack.newest
    end

    def slack_params
      params.require(:config_slack).permit(settings: %i[webhook_url channel])
    end
  end
end
