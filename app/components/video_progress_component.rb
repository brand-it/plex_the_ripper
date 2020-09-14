# frozen_string_literal: true

class VideoProgressComponent < ViewComponent::Base
  def initialize(video:) # rubocop:disable Lint/MissingSuper
    @video = video
  end
end
