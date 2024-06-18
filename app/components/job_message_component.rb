# frozen_string_literal: true

class JobMessageComponent < ViewComponent::Base
  extend Dry::Initializer
  option :job, Types.Instance(::Job)

  def dom_id
    "message-component-#{job.id}"
  end

  def message
    job.metadata['message']&.join("\n")
  end
end
