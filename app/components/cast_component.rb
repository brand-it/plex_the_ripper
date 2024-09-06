# frozen_string_literal: true

class CastComponent < ViewComponent::Base
  include ImdbHelper
  Member = Types::Hash.schema(
    character: Types::String,
    name: Types::String,
    profile_path: Types::String.optional
  ).with_key_transform(&:to_sym)
  Cast = Types::Coercible::Array.of(Member)

  extend Dry::Initializer
  option :video, Types.Instance(::Video)

  strip_trailing_whitespace

  def cast
    return [] if video.credits.nil?

    @cast ||= Cast[video.credits['cast']]
  end

  def render?
    cast.any?
  end
end
