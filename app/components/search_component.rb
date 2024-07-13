# frozen_string_literal: true

class SearchComponent < ViewComponent::Base
  extend Dry::Initializer

  option :search_service, Types.Instance(::VideoSearchQuery), default: -> { VideoSearchQuery.new }
end
