# frozen_string_literal: true

class SearchComponent < ViewComponent::Base
  extend Dry::Initializer

  option :search_service, Types.Instance(::VideoSearchQuery), default: -> { VideoSearchQuery.new }
  option :submit_on_key_up, Types::Coercible::Bool, default: -> { true }

  def form_data
    if submit_on_key_up
      {
        turbo_frame: 'videos',
        turbo_action: 'replace',
        controller: 'submit-on-keyup'
      }
    else
      {
        turbo_frame: 'videos',
        turbo_action: 'replace'
      }
    end
  end

  def input_html
    return {} unless submit_on_key_up

    {
      data: {
        action: 'keyup->submit-on-keyup#submitWithDebounce',
        submit_on_keyup_target: :input
      }
    }
  end
end
