# frozen_string_literal: true

class ProcessComponent < ViewComponent::Base
  extend Dry::Initializer
  option :dom_id, Types::String
  renders_one :body
  renders_one :link

  def title
    default = worker.name.demodulize.titleize
    I18n.t("processes.#{worker.name.underscore.dasherize}.title", default:)
  end
end
