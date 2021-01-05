# frozen_string_literal: true

# == Schema Information
#
# Table name: configs
#
#  id         :integer          not null, primary key
#  settings   :text
#  type       :string           default("Config"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Config
  class User < Config
    settings(
      dark_mode: true,
      the_movie_db_api_key: nil,
      the_movie_db_session_id: nil
    )
  end
end
