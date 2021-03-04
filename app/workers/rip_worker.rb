# frozen_string_literal: true

class RipWorker < ApplicationWorker
  class ProgressNotification
    extend Dry::Initializer

    option :completed, default: -> { 0 }
    option :title, default: -> { 'Loading...' }

    def call(mkv_message)
      case mkv_message
      when MkvParser::PRGV
        update_progress_bar(mkv_message.current.to_f / mkv_message.total.to_f) # rubocop:disable Style/FloatDivision
      when MkvParser::PRGT, MkvParser::PRGC
        self.title = mkv_message.name
      end
    end

    def update_progress_bar(completed)
      component = ProgressBarComponent.new(
        model: Disk,
        completed: completed, status: :info, message: title
      )
      cable_ready[DiskChannel.channel_name].morph(
        selector: "##{component.dom_id}",
        html: render(component, layout: false)
      )
      cable_ready.broadcast
    end
  end
  option :video_id, Types::Integer

  def call
    video.disk_titles.each do |title|
      CreateMkvService.new(disk_title: title, notify_progress: ProgressNotification.new).call
    end
  end

  def video
    @video ||= Video.includes(:disk_titles).find(video_id)
  end
end
