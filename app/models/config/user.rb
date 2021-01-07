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
    setting :dark_mode, default: -> { true }
    setting :the_movie_db_api_key
    setting :the_movie_db_session_id
  end
end
