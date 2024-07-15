# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def unmark_for_destruction
    return unless instance_variable_defined?(:@marked_for_destruction)

    remove_instance_variable(:@marked_for_destruction)
  end
end
