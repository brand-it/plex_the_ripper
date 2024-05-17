# frozen_string_literal: true

class MkvProgressListener
  extend Dry::Initializer
  include CableReady::Broadcaster

  delegate :render, to: :ApplicationController

  attr_reader :title, :message

  option :completed, Types::Coercible::Float.optional, default: -> { 0.0 }
  option :job, Types.Instance(Job)

  def call(mkv_message) # rubocop:disable Metrics/MethodLength
    case mkv_message
    when MkvParser::PRGV
      @completed = percentage(mkv_message.current, mkv_message.pmax)
      update_progress_bar
    when MkvParser::PRGT, MkvParser::PRGC
      @title = mkv_message.name
      job.update!(metadata: job.metadata.merge(title: @title))
    when MkvParser::MSG
      store_message(mkv_message.message)
      update_message_component
    end
  end

  def store_message(mkv_message)
    return if mkv_message.blank?

    @message ||= []
    @message << mkv_message
    @message.compact_blank!
    job.update!(metadata: job.metadata.merge(message: message.join("\n")))
  end

  def percentage(completed, total)
    return 0 if total.to_i.zero?

    percent = completed / total
    return 0 if percent.nan?

    (percent * 100).round(2)
  end

  def update_message_component
    component = ProgressMessageComponent.new(model: DiskTitle, message: message.join("\n"))
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
    @next_update = nil
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

  def next_update
    @next_update ||= 0.5.seconds.from_now
  end
end
