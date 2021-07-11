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
    setting do |s|
      s.attribute :movie_path
      s.attribute :video_path
      s.attribute :ftp_username
      s.attribute :ftp_host
      s.attribute :ftp_password, encrypted: true
      s.attribute :use_ftp
    end

    validates :settings_movie_path, presence: true
    validates :settings_video_path, presence: true
  end
end
