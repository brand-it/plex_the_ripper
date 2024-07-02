# frozen_string_literal: true

class CheckForUpgradeService
  Result = Struct.new(:upgrade, :version)
  REPO = 'brand-it/plex_the_ripper'
  API_URL = "https://api.github.com/repos/#{REPO}/releases/latest".freeze

  def self.call
    new.call
  end

  def call
    Result.new(newer_version?, latest_version)
  end

  def newer_version?
    return false if release_info['tag_name'].blank?

    release_version = Gem::Version.new(release_info['tag_name']&.gsub('v', ''))
    current_version = Gem::Version.new(PlexRipper::VERSION)
    release_version > current_version
  end

  def release_info
    Rails.cache.fetch('new_version_available', expires_in: 24.hours) do
      uri = URI(API_URL)
      response = Net::HTTP.get(uri)
      JSON.parse(response)
    end
  rescue StandardError
    {}
  end
end
