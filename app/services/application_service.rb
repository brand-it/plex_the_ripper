# frozen_string_literal: true

class ApplicationService
  class Error < StandardError; end

  extend Dry::Initializer
  include Wisper::Publisher

  def self.call(...)
    new(...).call
  end
end
