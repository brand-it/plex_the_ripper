# frozen_string_literal: true

module IconHelper
  def icon(icon_name, options = {})
    options[:type] ||= 'fa'
    check_icon_type(options[:type])
    classes = [
      options[:type],
      icon_class_size(options.delete(:size)),
      "fa-#{icon_name}",
      options[:class]
    ].compact
    content_tag :i, nil, class: classes
  end

  private

  def icon_class_size(size)
    return if size.blank?

    check_icon_size(size)
    "fa-#{size}"
  end

  def check_icon_type(type)
    types = %w[fa fal fab fas far]
    raise "#{type.inspect} is not know type" unless types.include?(type)
  end

  def check_icon_size(size)
    sizes = %w[xs sm lg 2 3 5 7 10]
    raise "#{size.inspect} is not valid please pick from list #{sizes.join(', ')}" unless sizes.include?(size)
  end
end
