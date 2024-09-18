# frozen_string_literal: true

module Types
  include Dry.Types()
  Coercible::StrippedString = Coercible::String.constructor { |value| value.to_s.strip }

  Coercible::Bool = Bool.constructor { |value| ActiveModel::Type::Boolean.new.cast(value) }
end
