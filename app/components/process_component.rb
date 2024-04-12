# frozen_string_literal: true

class ProcessComponent < ViewComponent::Base
  extend Dry::Initializer
  option :worker, Types.Interface(:name)
  renders_one :body

  def dom_id
    "#{worker.name.underscore.dasherize}-process"
  end

  def title
    default = worker.name.demodulize.titleize
    I18n.t("processes.#{worker.name.underscore.dasherize}.title", default:)
  end
end
