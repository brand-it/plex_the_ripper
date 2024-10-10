# frozen_string_literal: true

class UploadProgressListener
  extend Dry::Initializer
  include SlackUtility
  include CableReady::Broadcaster

  delegate :render, to: :ApplicationController

  option :video_blob, Types.Instance(::VideoBlob)
  option :job, Types.Instance(::Job)

  attr_reader :completed

  def upload_progress(tracker:)
    update_meta_from_tracker(tracker)
    return if next_update.future?

    job.save!
    update_component
    @next_update = 1.second.from_now
  end

  def upload_ready
    upload_started
  end

  def upload_started(tracker: nil)
    update_meta_from_tracker(tracker)
    job.metadata['video_blob_id'] = video_blob.id
    job.save!
    update_component
  end

  def upload_finished(tracker:)
    update_meta_from_tracker(tracker)
    job.save!
    video_blob.update!(uploadable: false, uploaded_on: Time.current)
    update_component
  end

  def upload_error(exception)
    job.metadata['message'] = exception.message
    job.save!
  end

  private

  def update_meta_from_tracker(tracker)
    return if tracker.nil?

    job.completed = tracker.percentage_component.percentage_with_precision
    job.metadata['eta'] = tracker.time_component.estimated_without_label
    job.metadata['rate'] = "#{tracker.rate_component.rate_of_change_with_precision} KB/sec"
    job.metadata['progress'] = "#{tracker.progress} KB"
  end

  def update_component
    component = UploadProcessComponent.new
    cable_ready[BroadcastChannel.channel_name].morph \
      selector: "##{component.dom_id}",
      html: render(component, layout: false)
    cable_ready.broadcast
  end

  def next_update
    @next_update ||= 1.second.from_now
  end
end
