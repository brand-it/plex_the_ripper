# frozen_string_literal: true

module Types
  include Dry.Types()
  Coercible::StrippedString = Coercible::String.constructor { |value| value.to_s.strip }
end
