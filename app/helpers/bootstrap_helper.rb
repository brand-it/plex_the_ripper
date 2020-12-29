# frozen_string_literal: true

module BootstrapHelper
  def light_dark_mode
    cookies[:light_dark_mode] || 'dark'
  end

  def bootstrap_alerts
    alerts = []
    flash.each do |type, message|
      alerts << tag.div(class: "alert #{type_to_boostrap_class(type)} alert-dismissiable fade show") do
        concat message
        concat close_button
      end
    end
    safe_join(alerts)
  end

  def close_button
    tag.button(icon('times-circle'), type: 'button',
                                     class: 'close',
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
