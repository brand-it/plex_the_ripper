# frozen_string_literal: true

class RipWorker < ApplicationWorker
  option :disk_title_ids, Types::Array.of(Types::Integer)
  attr_reader :progress_notification

  def call
    Rails.logger.debug("Ripping Titles #{disk_titles.count}")
    @progress_notification = ProgressNotification.new
    disk_titles.each do |title|
      CreateMkvService.new(disk_title: title, notify_progress: progress_notification).call
    end
  end

  def disk_titles
    @disk_titles ||= DiskTitle.where(id: disk_title_ids)
  end

  class ProgressNotification
    extend Dry::Initializer
    include CableReady::Broadcaster

    delegate :render, to: :ApplicationController

    option :completed, Types::Integer.optional, default: -> { 0 }
    option :title, Types::String.optional, default: -> { 'Loading...' }
    option :message, Types::String.optional, default: -> { '' }

    def call(mkv_message) # rubocop:disable Metrics/MethodLength
      Rails.logger.debug("ProgressNotification #{mkv_message}")
      case mkv_message
      when MkvParser::PRGV
        @completed = percentage(mkv_message.current, mkv_message.pmax)
        update_progress_bar
      when MkvParser::PRGT, MkvParser::PRGC
        @title = mkv_message.name
      when MkvParser::MSG
        @message += "#{mkv_message.message}\n"
        update_message_component
      else
        Rails.logger.debug("ProgressNotification unknown progress #{mkv_message}")
      end
    end

    def percentage(completed, total)
      return 0 if total.to_i.zero?

      percent = completed / total
      return 0 if percent.nan?

      (percent * 100).round(2)
    end

    def update_message_component
      component = ProgressMessageComponent.new model: DiskTitle, message: message
      cable_ready[DiskTitleChannel.channel_name].morph(
        selector: "##{component.dom_id}",
        html: render(component, layout: false)
      )
      cable_ready.broadcast
    end

    def update_progress_bar
      component = ProgressBarComponent.new(
        model: DiskTitle,
        completed: completed, status: :info, message: title
      )
      Rails.logger.debug("ProgressNotification completed #{component.dom_id} #{title} #{completed}")
      cable_ready[DiskTitleChannel.channel_name].morph(
        selector: "##{component.dom_id}",
        html: render(component, layout: false)
      )
      cable_ready.broadcast
    end
  end
end
