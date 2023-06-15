# frozen_string_literal: true

module ImdbHelper
  def imdb_image_tag(path, width: nil, height: nil, klass: 'img-fluid')
    if path.blank?
      image_tag 'placeholder_poster.jpg', class: klass, width: width, height: height
    else
      image_tag image_path(path.delete('/'), dimension: 'w500'), class: klass, width: width, height: height,
                                                                 loading: 'lazy'
    end
  end
end
