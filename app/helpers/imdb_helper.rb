# frozen_string_literal: true

module ImdbHelper
  def imdb_image_tag(path, width: 500, klass: 'card-img-top')
    if path.blank?
      image_pack_tag 'media/images/placeholder_poster.jpg', width: width, class: klass
    else
      image_tag "https://image.tmdb.org/t/p/w#{width}/#{path}", class: klass
    end
  end
end
