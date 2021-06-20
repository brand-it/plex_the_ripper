# frozen_string_literal: true

module ImdbHelper
  def imdb_image_tag(path, width: nil, height: nil, klass: 'img-fluid')
    if path.blank?
      image_pack_tag 'media/images/placeholder_poster.jpg', class: klass, width: width, height: height
    else
      image_tag "https://image.tmdb.org/t/p/w500/#{path}", class: klass, width: width, height: height
    end
  end
end
