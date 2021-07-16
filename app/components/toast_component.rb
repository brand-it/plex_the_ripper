# frozen_string_literal: true

class ToastComponent < ViewComponent::Base
  renders_one :header, ToastHeaderComponent
  renders_one :body
end
