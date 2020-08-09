# frozen_string_literal: true

module BootstrapHelper
  def bootstrap_alerts
    alerts = []
    flash.each do |type, message|
      alerts << content_tag(:div, class: "alert #{type_to_boostrap_class(type)} alert-dismissiable fade show") do
        concat message
        concat(
          content_tag(
            :button,
            icon('times-circle'),
            type: 'button',
            class: 'close',
            data: { dismiss: 'alert' },
            'aria-label' => 'Close'
          )
        )
      end
    end
    safe_join(alerts)
  end

  def type_to_boostrap_class(type)
    case type
    when 'alert', 'info'
      'alert-info'
    else
      'alert-secondary'
    end
  end
end
