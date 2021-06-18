# frozen_string_literal: true

module HasProgress
  extend ActiveSupport::Concern
  included do
    has_many :mkv_progresses, as: :progressable, dependent: :destroy
  end
end
