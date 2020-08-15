# frozen_string_literal: true

class User < ApplicationRecord
  belongs_to :config, polymorphic: true

  validates :name, presence: true
end
