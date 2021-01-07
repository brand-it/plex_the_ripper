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
    setting :movie_path
    setting :video_path
    setting :ftp_username
    setting :ftp_host
    setting :ftp_password
    setting :use_ftp

    validates :settings_movie_path, presence: true
    validates :settings_video_path, presence: true
  end
end
