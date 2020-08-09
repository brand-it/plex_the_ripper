# frozen_string_literal: true

module Types
  include Dry.Types()

  OpenStruct = Types.Constructor(OpenStruct)
end
