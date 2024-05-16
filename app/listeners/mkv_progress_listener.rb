# frozen_string_literal: true

class MkvProgressListener
  extend Dry::Initializer
  include CableReady::Broadcaster

  delegate :render, to: :ApplicationController

  option :completed, Types::Coercible::Float.optional, default: -> { 0.0 }
  option :title, Types::String.optional, default: -> { 'Loading...' }
  option :message, Types::String.optional, default: -> { '' }

  def call(mkv_message)
    case mkv_message
    when MkvParser::PRGV
      @completed = percentage(mkv_message.current, mkv_message.pmax)
      update_progress_bar
    when MkvParser::PRGT, MkvParser::PRGC
      @title = mkv_message.name
    when MkvParser::MSG
      @message += "#{mkv_message.message}\n"
      update_message_component
    end
  end

  def percentage(completed, total)
    return 0 if total.to_i.zero?

    percent = completed / total
    return 0 if percent.nan?

    (percent * 100).round(2)
  end

  def update_message_component
    component = ProgressMessageComponent.new(model: DiskTitle, message:)
    cable_ready[DiskTitleChannel.channel_name].morph(
      selector: "##{component.dom_id}",
      html: render(component, layout: false)
    )
    cable_ready.broadcast
  end

  def update_progress_bar
    cable_ready[DiskTitleChannel.channel_name].morph \
      selector: "##{component.dom_id}",
      html: render(component, layout: false)
    cable_ready.broadcast
  end

  def component # rubocop:disable Metrics/MethodLength
    progress_bar = render(
      ProgressBarComponent.new(
        model: DiskTitle,
        completed:,
        status: :info,
        message: title
      ), layout: false
    )
    component = ProcessComponent.new(worker: RipWorker)
    component.with_body { progress_bar }
    component
  end
end
