# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  include CableReady::Broadcaster

  scope :newest, -> { order(created_at: :desc) }
  self.abstract_class = true

  def unmark_for_destruction
    return unless instance_variable_defined?(:@marked_for_destruction)

    remove_instance_variable(:@marked_for_destruction)
  end
end
