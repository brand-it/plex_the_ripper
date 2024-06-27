# frozen_string_literal: true

module ImdbHelper
  def imdb_image_tag(path, width: 500, height: nil, klass: 'img-fluid')
    if path.blank?
      image_tag('placeholder_poster.jpg', class: klass, width:, height:)
    else
      image_tag image_path(path.delete('/'), dimension: "w#{lookup_wwmidth(width)}"), class: klass, width:, height:,
                                                                                      loading: 'lazy'
    end
  end

  private

  def lookup_wwmidth(width)
    case width.to_i
    when 1...300
      200
    when 301...1000
      500
    end
  end
end
