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
  class Plex < Config
    settings(
      movie_path: nil,
      video_path: nil,
      ftp_username: nil,
      ftp_host: nil,
      ftp_password: nil,
      use_ftp: false
    )

    validates :settings_movie_path, presence: true
    validates :settings_video_path, presence: true
  end
end
