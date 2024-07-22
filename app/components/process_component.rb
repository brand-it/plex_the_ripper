# frozen_string_literal: true

class ProcessComponent < ViewComponent::Base
  extend Dry::Initializer
  option :dom_id, Types::String
  renders_one :title
  renders_one :body
  renders_one :link
end
