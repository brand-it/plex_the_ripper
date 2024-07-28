# frozen_string_literal: true

class UploadProgressListener
  extend Dry::Initializer
  include SlackUtility
  include CableReady::Broadcaster

  delegate :render, to: :ApplicationController

  option :video_blob, Types.Instance(::VideoBlob)
  option :file_size, Types::Integer
  option :job, Types.Instance(::Job)

  attr_reader :completed

  def upload_progress(chunk_size: nil)
    job.metadata['completed'] ||= 0
    job.metadata['completed'] += chunk_size
    return if next_update.future?

    job.save!
    update_component
    @next_update = 1.second.from_now
  end

  def upload_start
    job.metadata['completed'] ||= 0
    job.metadata['video_blob_id'] = video_blob.id
    job.save!
    update_component
  end

  def upload_finished
    job.metadata['completed'] = file_size
    job.save!
    video_blob.update!(uploadable: false, uploaded_on: Time.current)
    update_component
  end

  def upload_error
    job.metadata
    job.save!
  end

  private

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
