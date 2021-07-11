# frozen_string_literal: true

module BootstrapHelper
  def light_dark_mode
    cookies[:light_dark_mode] || 'dark'
  end

  def bootstrap_alerts
    alerts = []
    flash.each do |type, message|
      alerts << tag.div(class: "row alert #{type_to_boostrap_class(type)} rounded-0 alert-dismissiable fade show") do
        concat tag.span(message, class: 'col-11')
        concat close_button
      end
    end
    safe_join(alerts)
  end

  def close_button
    tag.span(icon('times-circle'), type: 'button',
                                   class: 'close col-1 text-end',
                                   data: { dismiss: 'alert' },
                                   'aria-label' => 'Close')
  end

  def type_to_boostrap_class(type)
    case type
    when 'alert', 'info' then 'alert-info'
    when 'success' then 'alert-success'
    when 'error' then 'alert-danger'
    when 'warn' then 'alert-warning'
    else 'alert-secondary' end
  end
end
